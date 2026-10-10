#!/usr/bin/env python3
# Store one GPG passphrase in the calling user's Secret Service, once per
# keygrip. Root keeps its own item on the root-only bus; this program does
# not change uid. The collection must already be unlocked. The passphrase
# is not written into the Nix store.

import getpass
import os
import subprocess
import sys

SCHEMA = "org.nixos-home.pinentry-howdy"
SECRET_TOOL = "@secretTool@"
ROOT_BUS = os.environ.get("PINENTRY_HOWDY_ROOT_BUS", "/run/pinentry-howdy/root.bus")


def usage():
    sys.stderr.write(
        "usage: pinentry-howdy-enroll KEYGRIP...\n"
        "Reads one passphrase and stores it for each 40-hex keygrip.\n"
        "Root uses its own Secret Service. Other users use their session bus.\n"
        "The collection must already be unlocked.\n"
    )
    sys.exit(2)


def grips(argv):
    if not argv:
        usage()
    out = []
    for raw in argv:
        grip = raw.strip().upper()
        if len(grip) != 40 or any(c not in "0123456789ABCDEF" for c in grip):
            sys.stderr.write(f"not a keygrip: {raw}\n")
            sys.exit(2)
        out.append(grip)
    return out


def read_secret() -> bytes:
    if sys.stdin.isatty():
        first = getpass.getpass("GPG passphrase: ")
        again = getpass.getpass("Repeat: ")
        if first != again:
            sys.stderr.write("passphrases do not match\n")
            sys.exit(1)
        if not first:
            sys.stderr.write("empty passphrase\n")
            sys.exit(1)
        return first.encode()
    data = sys.stdin.buffer.read()
    if data.endswith(b"\n"):
        data = data[:-1]
    if not data:
        sys.stderr.write("empty passphrase\n")
        sys.exit(1)
    return data


def session_env():
    env = os.environ.copy()
    if os.geteuid() == 0:
        if not os.path.exists(ROOT_BUS):
            sys.stderr.write(
                f"root Secret Service is not running ({ROOT_BUS}).\n"
            )
            sys.exit(1)
        env["DBUS_SESSION_BUS_ADDRESS"] = f"unix:path={ROOT_BUS}"
        env["HOME"] = "/root"
        env.pop("XDG_RUNTIME_DIR", None)
        return env
    bus = f"/run/user/{os.getuid()}/bus"
    if os.path.exists(bus):
        env["DBUS_SESSION_BUS_ADDRESS"] = f"unix:path={bus}"
        return env
    if env.get("DBUS_SESSION_BUS_ADDRESS"):
        return env
    sys.stderr.write(
        f"no session bus at {bus}.\n"
        "Open the graphical session and unlock the wallet first.\n"
    )
    sys.exit(1)


def main():
    chosen = grips(sys.argv[1:])
    env = session_env()
    secret = read_secret() + b"\n"
    for grip in chosen:
        result = subprocess.run(
            [
                SECRET_TOOL, "store",
                "--label", f"GPG {grip}",
                "xdg:schema", SCHEMA,
                "keygrip", grip,
            ],
            input=secret,
            env=env,
        )
        if result.returncode != 0:
            sys.exit(result.returncode)
        sys.stderr.write(f"stored {grip}\n")


if __name__ == "__main__":
    main()
