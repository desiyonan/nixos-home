"""Run with the stagingSystem output from check.nix as the sole argument."""

import contextlib
import http.client
import http.server
import os
from pathlib import Path
import re
import shlex
import socket
import ssl
import subprocess
import sys
import tempfile
import threading
import time


DOMAIN = "hs.dnfn.tech"


class ControlServer(http.server.BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    requests = []

    def respond(self):
        self.requests.append((self.command, self.path, dict(self.headers)))
        if self.path == "/ts2021":
            self.send_response(101)
            self.send_header("Upgrade", self.headers["Upgrade"])
            self.send_header("Connection", "upgrade")
            self.end_headers()
        else:
            self.send_response(200)
            self.send_header("Content-Length", "0")
            self.end_headers()

    do_GET = respond
    do_POST = respond

    def log_message(self, *_):
        pass


def openssl(directory, *args):
    subprocess.run(["openssl", *args], cwd=directory, check=True, capture_output=True)


def make_certificates(directory):
    for name in ("root", "issuer", "leaf"):
        args = ["req", "-new", "-newkey", "ec", "-pkeyopt", "ec_paramgen_curve:P-256",
                "-nodes", "-subj", f"/CN={DOMAIN if name == 'leaf' else name}",
                "-keyout", f"{name}.key"]
        if name == "root":
            openssl(directory, *args, "-x509", "-days", "2", "-out", "root.pem",
                    "-addext", "basicConstraints=critical,CA:TRUE",
                    "-addext", "keyUsage=critical,keyCertSign,cRLSign")
        else:
            openssl(directory, *args, "-out", f"{name}.csr")
    (directory / "issuer.ext").write_text("basicConstraints=critical,CA:TRUE,pathlen:0\n"
                                          "keyUsage=critical,keyCertSign,cRLSign\n")
    (directory / "leaf.ext").write_text(f"subjectAltName=DNS:{DOMAIN}\nextendedKeyUsage=serverAuth\n")
    for name, ca in (("issuer", "root"), ("leaf", "issuer")):
        openssl(directory, "x509", "-req", "-in", f"{name}.csr", "-CA", f"{ca}.pem",
                "-CAkey", f"{ca}.key", "-CAcreateserial", "-days", "1",
                "-extfile", f"{name}.ext", "-out", f"{name}.pem")
    (directory / "fullchain.pem").write_bytes(
        (directory / "leaf.pem").read_bytes() + (directory / "issuer.pem").read_bytes()
    )


def request(port, context, method, path, **headers):
    with socket.create_connection(("127.0.0.1", port), timeout=5) as raw:
        with context.wrap_socket(raw, server_hostname=DOMAIN) as tls:
            headers = {"Host": f"{DOMAIN}:18443", "Connection": "close", **headers}
            message = f"{method} {path} HTTP/1.1\r\n"
            message += "".join(f"{name}: {value}\r\n" for name, value in headers.items()) + "\r\n"
            tls.sendall(message.encode())
            response = http.client.HTTPResponse(tls)
            response.begin()
            response.read()
            return response.status


def verify_routes(port, context):
    assert request(port, context, "GET", "/key?v=142", **{
        "Authorization": "Bearer mock", "X-Forwarded-For": "198.51.100.1",
    }) == 200
    assert request(port, context, "GET", "/register/regid_example?ignored=1") == 200
    assert request(port, context, "POST", "/ts2021", **{
        "Connection": "Upgrade", "Upgrade": "tailscale-control-protocol",
        "X-Tailscale-Handshake": "mock-handshake", "Content-Length": "0",
    }) == 101
    assert request(port, context, "POST", "/ts2021", **{"Upgrade": "websocket"}) == 426
    assert request(port, context, "PUT", "/ts2021") == 405
    assert request(port, context, "POST", "/key") == 405
    assert request(port, context, "GET", "/key", Host="unexpected.example") == 421
    for path in ("/", "/admin", "/api", "/api/v1/node", "/%61pi/v1/node", "/swagger",
                 "/metrics", "/debug", "/verify", "/derp", "/oidc/callback",
                 "/register/a/../../api", "/ts2021/../api", "/key/anything"):
        assert request(port, context, "GET", path) == 404, path

    key, registration, upgrade = ControlServer.requests
    assert key[:2] == ("GET", "/key?v=142")
    assert "Authorization" not in key[2]
    assert key[2]["X-Forwarded-For"] == "127.0.0.1"
    assert registration[:2] == ("GET", "/register/regid_example")
    assert upgrade[:2] == ("POST", "/ts2021")
    assert upgrade[2]["Upgrade"] == "tailscale-control-protocol"
    assert upgrade[2]["Connection"] == "upgrade"
    assert upgrade[2]["X-Tailscale-Handshake"] == "mock-handshake"


def verify_reload(path):
    with tempfile.TemporaryDirectory() as tmp:
        directory = Path(tmp)
        certificate = directory / "headscale-service-staging"
        certificate.mkdir()
        calls = directory / "calls"
        systemctl = directory / "systemctl"
        systemctl.write_text('#!/bin/sh\nprintf "%s\\n" "$*" >> "$MOCK_SYSTEMCTL_CALLS"\n')
        systemctl.chmod(0o700)
        hook = directory / "postrun"
        hook.write_text(Path(path).read_text().replace("/var/lib/acme/", tmp + "/"))
        hook.chmod(0o700)
        env = {**os.environ, "PATH": f"{tmp}:{os.environ['PATH']}", "MOCK_SYSTEMCTL_CALLS": str(calls)}
        subprocess.run([hook], env=env, check=True)
        assert not calls.exists()
        renewed = certificate / "renewed"
        renewed.touch()
        subprocess.run([hook], env=env, check=True)
        assert not renewed.exists()
        subprocess.run([hook], env=env, check=True)
        assert calls.read_text().splitlines() == ["--no-block try-reload-or-restart nginx.service"]
    print("PASS: generated renewal hook reloads once when a new certificate is installed")


def main(system):
    units = system / "etc/systemd/system"
    nginx = (units / "nginx.service").read_text()
    start = next(line.split("=", 1)[1] for line in nginx.splitlines()
                 if line.startswith("ExecStart="))
    command = shlex.split(start)
    binary = command[0]
    config = Path(command[command.index("-c") + 1]).read_text()
    order = (units / "acme-order-renew-headscale-service-staging.service").read_text()
    reload_hook = next(line.removeprefix("ExecStartPost=+") for line in order.splitlines()
                       if line.startswith("ExecStartPost=+"))

    with tempfile.TemporaryDirectory() as tmp, http.server.ThreadingHTTPServer(
        ("127.0.0.1", 0), ControlServer
    ) as upstream:
        directory = Path(tmp)
        thread = threading.Thread(target=upstream.serve_forever, daemon=True)
        thread.start()
        make_certificates(directory)
        with contextlib.closing(socket.socket()) as sock:
            sock.bind(("127.0.0.1", 0))
            port = sock.getsockname()[1]

        assert re.findall(r"^\s*listen\s+(.*?)\s*;", config, re.M) == ["127.0.0.1:18443 ssl"]
        config = config.replace("127.0.0.1:18443", f"127.0.0.1:{port}")
        config = config.replace("127.0.0.1:28080", f"127.0.0.1:{upstream.server_port}")
        config = re.sub(r"/var/lib/acme/[^/]+/(fullchain.pem|key.pem)",
                        lambda match: str(directory / ("leaf.key" if match[1] == "key.pem" else match[1])),
                        config)
        config = re.sub(r"/(run|var/(cache|log))/nginx", tmp, config)
        config_file = directory / "nginx.conf"
        config_file.write_text(config)
        args = [binary, "-p", tmp, "-c", str(config_file), "-e", "stderr"]
        subprocess.run([*args, "-t"], check=True)
        process = subprocess.Popen(args)
        try:
            context = ssl.create_default_context(cafile=str(directory / "root.pem"))
            for _ in range(100):
                if process.poll() is not None:
                    raise RuntimeError("nginx exited during startup")
                try:
                    with socket.create_connection(("127.0.0.1", port), timeout=0.1):
                        break
                except ConnectionRefusedError:
                    time.sleep(0.05)
            verify_routes(port, context)
        finally:
            process.terminate()
            process.wait(timeout=10)
            upstream.shutdown()
            thread.join(timeout=5)
    print("PASS: TLS with an intermediate chain, TS2021 upgrade, and route allowlist")
    verify_reload(reload_hook)


if __name__ == "__main__":
    main(Path(sys.argv[1]))
