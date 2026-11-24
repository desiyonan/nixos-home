"""Update an existing Cloudflare DNS-only address record."""

import http.client
import ipaddress
import json
import os
from pathlib import Path
import re
import subprocess
import sys
from urllib.parse import urlencode


ADDRESS_TYPES = {
    "A": ("-4", "inet", ipaddress.IPv4Address),
    "AAAA": ("-6", "inet6", ipaddress.IPv6Address),
}
DNS_LABEL = re.compile(r"[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?", re.ASCII)
INTERFACE_NAME = re.compile(r"[a-zA-Z0-9][a-zA-Z0-9_.-]{0,14}", re.ASCII)
IDENTIFIER = re.compile(r"[0-9a-f]{32}", re.ASCII)
MAX_RESPONSE = 1024 * 1024


class UpdateError(Exception):
    """A diagnostic safe to send to the journal."""


def read_settings():
    path = os.environ.get("NIXOS_ROUTER_DDNS_SETTINGS_FILE")
    if not path:
        return {}
    try:
        settings = json.loads(Path(path).read_text(encoding="utf-8"))
        if not isinstance(settings, dict):
            raise ValueError
        return settings
    except FileNotFoundError:
        return {}
    except (OSError, ValueError, RecursionError):
        raise UpdateError("could not read saved DDNS settings") from None


def read_target(settings=None):
    try:
        target = json.loads(os.environ["NIXOS_ROUTER_MANAGED_DDNS_CONFIG"])
        name = (settings or {}).get("record", target.get("record", ""))
        record_type, interface = target["recordType"], target["interface"]
        if not name and not settings:
            return None
        if (len(name) > 253 or "." not in name
                or not all(DNS_LABEL.fullmatch(label) for label in name.split("."))
                or record_type not in ADDRESS_TYPES or not INTERFACE_NAME.fullmatch(interface)):
            raise ValueError
        return name, record_type, interface
    except (KeyError, TypeError, ValueError, RecursionError):
        raise UpdateError("invalid DDNS target (expected domain, A/AAAA and interface)") from None


def public_address(interface_name, record_type):
    ip_option, family, address_type = ADDRESS_TYPES[record_type]
    try:
        interfaces = json.loads(subprocess.run(
            ["ip", "-j", ip_option, "address", "show"], check=True, capture_output=True,
            text=True, timeout=5,
        ).stdout)
        addresses = set()
        for interface in interfaces:
            if interface["ifname"] != interface_name:
                continue
            for entry in interface["addr_info"]:
                if (entry.get("family") != family or entry.get("scope") != "global"
                        or any(entry.get(flag) for flag in ("tentative", "dadfailed", "deprecated", "temporary"))
                        or entry.get("valid_life_time") == 0
                        or entry.get("preferred_life_time") == 0):
                    continue
                try:
                    local = entry.get("local")
                    if not isinstance(local, str):
                        continue
                    address = address_type(local)
                except ipaddress.AddressValueError:
                    continue
                if address.is_global and not (address.is_multicast or address.is_reserved):
                    addresses.add(str(address))
    except (OSError, subprocess.SubprocessError, ValueError, KeyError, TypeError, AttributeError):
        raise UpdateError(f"could not read {family} addresses from ip") from None
    if len(addresses) > 1:
        print(f"Skipping DDNS: multiple public {family} addresses on {interface_name}")
    elif not addresses:
        print(f"Skipping DDNS: no usable public {family} address on {interface_name}")
    else:
        return addresses.pop()
    return None


def read_credentials(settings=None):
    try:
        settings = settings or {}
        if settings.get("zoneId") or settings.get("apiToken"):
            zone, token = settings["zoneId"], settings["apiToken"]
        else:
            path = Path(os.environ["CREDENTIALS_DIRECTORY"]) / "cloudflare"
            data = json.loads(path.read_text(encoding="utf-8"))
            if data == {}:
                return None
            zone, token = data["zone_id"], data["api_token"]
        if not IDENTIFIER.fullmatch(zone) or not re.fullmatch(r"[A-Za-z0-9_-]+", token):
            raise ValueError
        return zone, token
    except (OSError, KeyError, TypeError, ValueError):
        raise UpdateError("missing or invalid Cloudflare credential (expected zone_id and api_token)") from None


def request(method, path, token, content=None):
    connection = http.client.HTTPSConnection("api.cloudflare.com", timeout=10)
    headers = {"Authorization": f"Bearer {token}", "Accept": "application/json"}
    body = None
    if content is not None:
        headers["Content-Type"] = "application/json"
        body = json.dumps({"content": content}).encode()
    try:
        connection.request(method, path, body=body, headers=headers)
        response = connection.getresponse()
        if response.status != 200:
            raise UpdateError(f"Cloudflare {method} returned HTTP {response.status}")
        raw = response.read(MAX_RESPONSE + 1)
        if len(raw) > MAX_RESPONSE:
            raise UpdateError(f"Cloudflare {method} response exceeded the size limit")
        payload = json.loads(raw)
    except TimeoutError:
        raise UpdateError(f"Cloudflare {method} timed out") from None
    except (OSError, http.client.HTTPException, ValueError, RecursionError):
        raise UpdateError(f"Cloudflare {method} transport or JSON response failed") from None
    finally:
        connection.close()
    if (not isinstance(payload, dict) or payload.get("success") is not True
            or payload.get("errors") != [] or "result" not in payload):
        raise UpdateError(f"Cloudflare {method} did not report success")
    return payload


def record_address(record, name, record_type):
    if not isinstance(record, dict):
        return None
    if (record.get("name") != name or record.get("type") != record_type
            or record.get("proxied") is not False
            or not isinstance(record.get("id"), str) or not IDENTIFIER.fullmatch(record["id"])
            or type(record.get("ttl")) is not int or record["ttl"] < 1
            or not isinstance(record.get("content"), str)):
        return None
    try:
        return str(ADDRESS_TYPES[record_type][2](record["content"]))
    except ipaddress.AddressValueError:
        return None


def update_record(address, zone, token, name, record_type):
    path = f"/client/v4/zones/{zone}/dns_records"
    query = urlencode({"type": record_type, "name.exact": name, "page": 1, "per_page": 2})
    # Include proxied records in the lookup so they also count toward ambiguity.
    listing = request("GET", f"{path}?{query}", token)
    records = listing["result"]
    info = listing.get("result_info")
    previous = record_address(records[0], name, record_type) if isinstance(records, list) and len(records) == 1 else None
    if (previous is None or not isinstance(info, dict)
            or any(type(info.get(key)) is not int or info[key] != 1
                   for key in ("count", "page", "total_pages"))
            or info.get("cursor")):
        raise UpdateError(f"Cloudflare did not return exactly one existing DNS-only {record_type} record for {name}")
    if previous == address:
        print(f"Cloudflare {record_type} record for {name} is unchanged")
        return

    record = records[0]
    updated = request("PATCH", f"{path}/{record['id']}", token, address)["result"]
    if (record_address(updated, name, record_type) != address or updated["id"] != record["id"]
            or updated["ttl"] != record["ttl"]):
        raise UpdateError(f"Cloudflare PATCH response did not confirm the updated DNS-only {record_type} record for {name}")
    print(f"Updated Cloudflare {record_type} record for {name}")


def main():
    try:
        settings = read_settings()
        target = read_target(settings)
        if target is None:
            print("Skipping DDNS: no domain configured")
            return 0
        name, record_type, interface = target
        address = public_address(interface, record_type)
        if address is not None:
            credentials = read_credentials(settings)
            if credentials is None:
                print("Skipping DDNS: no Cloudflare credential configured")
            else:
                update_record(address, *credentials, name, record_type)
    except UpdateError as error:
        print(f"DDNS failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
