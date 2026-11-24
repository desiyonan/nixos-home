import io
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import Mock, patch

import update


ZONE = "a" * 32
RECORD = {"id": "b" * 32, "name": "s01.dnfn.tech", "type": "A",
          "proxied": False, "content": "1.1.1.1", "ttl": 300, "comment": "keep"}
LIST_PATH = f"/client/v4/zones/{ZONE}/dns_records?type=A&name.exact=s01.dnfn.tech&page=1&per_page=2"
TOKEN = "mock-secret-token"


def response(payload, status=200):
    result = io.BytesIO(json.dumps(payload).encode())
    result.status = status
    return result


def listing(*records, **pagination):
    return response({"success": True, "errors": [], "result": list(records),
                     "result_info": {"count": len(records), "page": 1,
                                     "total_pages": 1, **pagination}})


class UpdateTests(unittest.TestCase):
    def invoke(self, addresses, responses=(), *, record=RECORD, interface="nr-ppp0"):
        record_type = record["type"]
        family = "inet" if record_type == "A" else "inet6"
        target = {"record": record["name"], "recordType": record_type, "interface": interface}
        ip = Mock(return_value=Mock(stdout=json.dumps([
            {"ifname": "other", "addr_info": [{"scope": "global", "family": "inet", "local": "9.9.9.9"}]},
            {"ifname": interface, "addr_info": [
                {"scope": "global", "family": family, "local": address} for address in addresses
            ]},
        ])))
        credentials = Mock(return_value=(ZONE, TOKEN))
        connection = Mock()
        connection.getresponse.side_effect = responses
        with (patch.dict(os.environ, {"NIXOS_ROUTER_MANAGED_DDNS_CONFIG": json.dumps(target)}),
              patch.object(subprocess, "run", ip),
              patch.object(update, "read_credentials", credentials),
              patch.object(update.http.client, "HTTPSConnection", return_value=connection) as https,
              patch("sys.stdout", new_callable=io.StringIO) as stdout,
              patch("sys.stderr", new_callable=io.StringIO) as stderr):
            status = update.main()
        ip.assert_called_once()
        self.assertIn("-4" if record_type == "A" else "-6", ip.call_args.args[0])
        self.assertNotIn(TOKEN, stderr.getvalue())
        self.assertNotIn(TOKEN, stdout.getvalue())
        self.assertEqual(https.call_count, connection.request.call_count)
        return status, connection, credentials, stderr.getvalue()

    def test_runtime_target_accepts_aaaa_and_rejects_invalid_values(self):
        target = {"record": "edge.example.net", "recordType": "AAAA", "interface": "wan0"}
        with patch.dict(os.environ, {"NIXOS_ROUTER_MANAGED_DDNS_CONFIG": json.dumps(target)}):
            self.assertEqual(update.read_target(), ("edge.example.net", "AAAA", "wan0"))
        for invalid in ({**target, "record": "bad..net"}, {**target, "interface": "-4"},
                        {**target, "recordType": "CNAME"}):
            with patch.dict(os.environ, {"NIXOS_ROUTER_MANAGED_DDNS_CONFIG": json.dumps(invalid)}):
                with self.assertRaises(update.UpdateError):
                    update.read_target()

    def test_aaaa_uses_configured_interface_record_and_canonical_address(self):
        record = {**RECORD, "name": "edge.example.net", "type": "AAAA",
                  "content": "2606:4700:4700:0:0:0:0:1111"}
        status, api, _, _ = self.invoke(["2606:4700:4700::1111"], [listing(record)],
                                        record=record, interface="wan0")
        self.assertEqual(status, 0)
        api.request.assert_called_once()
        self.assertIn("type=AAAA&name.exact=edge.example.net", api.request.call_args.args[1])

    def test_page_settings_override_target_and_credentials(self):
        with tempfile.TemporaryDirectory() as directory:
            settings = Path(directory) / "ddns-settings.json"
            settings.write_text(json.dumps({
                "record": "edge.example.net", "zoneId": ZONE, "apiToken": TOKEN,
            }), encoding="utf-8")
            default = {"record": "original.example.net", "recordType": "A", "interface": "wan0"}
            with patch.dict(os.environ, {
                "NIXOS_ROUTER_MANAGED_DDNS_CONFIG": json.dumps(default),
                "NIXOS_ROUTER_DDNS_SETTINGS_FILE": str(settings),
            }):
                saved = update.read_settings()
                self.assertEqual(update.read_target(saved), ("edge.example.net", "A", "wan0"))
                self.assertEqual(update.read_credentials(saved), (ZONE, TOKEN))

    def test_unchanged(self):
        status, api, _, _ = self.invoke(["1.1.1.1"], [listing(RECORD)])
        self.assertEqual(status, 0)
        api.request.assert_called_once()
        self.assertEqual(api.request.call_args.args[:2], ("GET", LIST_PATH))
        self.assertEqual(api.request.call_args.kwargs["headers"]["Authorization"], f"Bearer {TOKEN}")

    def test_changed_then_idempotent(self):
        updated = {**RECORD, "content": "8.8.8.8"}
        status, api, _, _ = self.invoke(["8.8.8.8"], [
            listing(RECORD), response({"success": True, "errors": [], "result": updated})
        ])
        self.assertEqual(status, 0)
        get, patch_record = api.request.call_args_list
        self.assertEqual(get.args[:2], ("GET", LIST_PATH))
        self.assertEqual(patch_record.args[:2], ("PATCH", LIST_PATH.split("?")[0] + "/" + RECORD["id"]))
        self.assertEqual(json.loads(patch_record.kwargs["body"]), {"content": "8.8.8.8"})
        status, api, _, _ = self.invoke(["8.8.8.8"], [listing(updated)])
        self.assertEqual((status, api.request.call_count), (0, 1))

    def test_unusable_or_ambiguous_addresses_do_not_call_api(self):
        for addresses in ([], ["10.0.0.1"], ["100.64.1.1"], ["192.0.2.1"], ["169.254.1.1"],
                          ["224.0.0.1"], ["240.0.0.1"], ["127.0.0.1"], ["::1"], ["bad"], [134744072],
                          ["1.1.1.1", "8.8.8.8"]):
            with self.subTest(addresses=addresses):
                status, api, credentials, _ = self.invoke(addresses)
                self.assertEqual(status, 0)
                api.request.assert_not_called()
                credentials.assert_not_called()

    def test_target_must_be_unique_existing_unproxied_a(self):
        for reply in (listing(), listing(RECORD, {**RECORD, "proxied": True}),
                      listing({**RECORD, "proxied": True}), listing({**RECORD, "proxied": 0}),
                      listing({**RECORD, "name": "other.dnfn.tech"}),
                      listing({**RECORD, "type": "AAAA"}), listing({**RECORD, "id": "../bad"}),
                      listing(RECORD, total_pages=2), listing(RECORD, cursor="next")):
            with self.subTest(reply=reply):
                status, api, _, error = self.invoke(["8.8.8.8"], [reply])
                self.assertEqual((status, api.request.call_count), (1, 1))
                self.assertTrue(error)

    def test_runtime_credential_file(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(
            os.environ, {"CREDENTIALS_DIRECTORY": directory}
        ):
            with self.assertRaises(update.UpdateError):
                update.read_credentials()
            credential = Path(directory) / "cloudflare"
            credential.write_text(json.dumps({"zone_id": ZONE, "api_token": TOKEN}), encoding="utf-8")
            self.assertEqual(update.read_credentials(), (ZONE, TOKEN))
            credential.write_text(json.dumps({"zone_id": ZONE, "api_token": TOKEN + "\n"}),
                                  encoding="utf-8")
            with self.assertRaises(update.UpdateError) as error:
                update.read_credentials()
            self.assertNotIn(TOKEN, str(error.exception))

    def test_api_failures_never_trigger_patch_or_leak_response(self):
        invalid_json = io.BytesIO(TOKEN.encode())
        invalid_json.status = 200
        for reply in (response({"error": TOKEN}, 403), response({"success": False, "errors": [TOKEN]}),
                      response({"success": True, "result": [RECORD]}), invalid_json, TimeoutError(TOKEN)):
            with self.subTest(reply=reply):
                status, api, _, error = self.invoke(["8.8.8.8"], [reply])
                self.assertEqual((status, api.request.call_count), (1, 1))
                self.assertTrue(error)

    def test_patch_response_must_confirm_target_address_and_ttl(self):
        for result in (RECORD, {**RECORD, "content": "8.8.8.8", "ttl": 1},
                       {**RECORD, "content": "8.8.8.8", "proxied": True}, {}):
            with self.subTest(result=result):
                status, api, _, error = self.invoke(["8.8.8.8"], [
                    listing(RECORD), response({"success": True, "errors": [], "result": result})
                ])
                self.assertEqual((status, api.request.call_count), (1, 2))
                self.assertTrue(error)


if __name__ == "__main__":
    unittest.main()
