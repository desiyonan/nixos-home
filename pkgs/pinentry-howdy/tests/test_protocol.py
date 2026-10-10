#!/usr/bin/env python3
# Drives pinentry-howdy without a camera or a real Secret Service.

import os
import socket
import subprocess
import sys
import tempfile
import textwrap
from pathlib import Path


def write_exec(path: Path, body: str):
    path.write_text(body)
    path.chmod(0o755)


def run(pinentry: str, env: dict, script: bytes) -> bytes:
    proc = subprocess.run(
        [pinentry],
        input=script,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env=env,
        timeout=10,
    )
    if proc.returncode != 0:
        raise SystemExit(f"pinentry exited {proc.returncode}: {proc.stderr!r}")
    return proc.stdout


def main():
    pinentry = sys.argv[1]
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        fallback_log = root / "fallback-getpin"
        write_exec(
            root / "fallback",
            textwrap.dedent(
                f"""\
                #!/bin/sh
                printf 'OK mock\\n'
                while IFS= read -r line; do
                  case "$line" in
                    GETPIN)
                      echo GETPIN >> {fallback_log}
                      printf 'D typed\\nOK\\n'
                      ;;
                    BYE)
                      printf 'OK\\n'
                      exit 0
                      ;;
                    *)
                      printf 'OK\\n'
                      ;;
                  esac
                done
                """
            ),
        )
        write_exec(
            root / "busctl",
            textwrap.dedent(
                """\
                #!/bin/sh
                printf 'aoao 1 "/item" 0\\n'
                """
            ),
        )
        write_exec(
            root / "secret-tool",
            textwrap.dedent(
                """\
                #!/bin/sh
                if [ "$1" = lookup ]; then
                  printf 's3cret%%\\n'
                  exit 0
                fi
                exit 1
                """
            ),
        )

        base = os.environ.copy()
        base.update(
            {
                "PINENTRY_HOWDY_FALLBACK": str(root / "fallback"),
                "PINENTRY_HOWDY_BUSCTL": str(root / "busctl"),
                "PINENTRY_HOWDY_SECRET_TOOL": str(root / "secret-tool"),
                "DBUS_SESSION_BUS_ADDRESS": "unix:path=/absent",
                "DISPLAY": "",
                "WAYLAND_DISPLAY": "",
            }
        )

        # No enrolled item: busctl is not consulted because the session bus
        # path does not exist and DBUS_SESSION_BUS_ADDRESS is set, so SearchItems
        # runs. Point busctl at a script that reports zero unlocked items.
        write_exec(
            root / "busctl-empty",
            "#!/bin/sh\nprintf 'aoao 0 0\\n'\n",
        )
        env = dict(base)
        env["PINENTRY_HOWDY_BUSCTL"] = str(root / "busctl-empty")
        env["PINENTRY_HOWDY_SOCK"] = str(root / "missing.sock")
        out = run(
            pinentry,
            env,
            b"SETKEYINFO s/00112233445566778899AABBCCDDEEFF00112233\nGETPIN\nBYE\n",
        )
        if b"D typed\n" not in out:
            raise SystemExit(f"expected typed fallback, got {out!r}")
        if fallback_log.read_text().count("GETPIN") != 1:
            raise SystemExit("fallback GETPIN count mismatch for empty search")

        # Enrolled item, face succeeds, secret contains a percent sign.
        sock_path = root / "compare.sock"
        server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        server.bind(str(sock_path))
        server.listen(1)
        server.settimeout(5)
        env = dict(base)
        env["PINENTRY_HOWDY_SOCK"] = str(sock_path)
        fallback_log.write_text("")
        proc = subprocess.Popen(
            [pinentry],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=env,
        )
        greet = proc.stdout.readline()
        if greet != b"OK Pleased to meet you\n":
            proc.kill()
            raise SystemExit(f"bad greeting {greet!r}")
        proc.stdin.write(b"SETKEYINFO s/00112233445566778899AABBCCDDEEFF00112233\n")
        proc.stdin.flush()
        if proc.stdout.readline() != b"OK\n":
            proc.kill()
            raise SystemExit("SETKEYINFO was not forwarded")
        proc.stdin.write(b"GETPIN\n")
        proc.stdin.flush()
        conn, _ = server.accept()
        conn.sendall(b"OK\n")
        conn.close()
        reply = proc.stdout.readline() + proc.stdout.readline()
        proc.stdin.write(b"BYE\n")
        proc.stdin.flush()
        proc.wait(timeout=5)
        if reply != b"D s3cret%25\nOK\n":
            raise SystemExit(f"expected escaped secret, got {reply!r} stderr={proc.stderr.read()!r}")
        if fallback_log.read_text().strip():
            raise SystemExit("fallback pinentry was asked for GETPIN after a face hit")
        server.close()

    print("ok")


if __name__ == "__main__":
    main()
