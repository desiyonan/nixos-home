#!/usr/bin/env python3
# One-shot Howdy compare for the peer uid. Started by systemd socket
# activation as root, so it does not go through sudo/polkit PAM (those
# stacks already contain pam_howdy and would scan twice).

import os
import pwd
import socket
import struct
import subprocess
import sys

PYTHON = "@howdyPython@"
COMPARE = "@comparePy@"
HOWDY_BIN = "@howdyBin@"


def peer_user():
    raw = socket.fromfd(
        sys.stdin.fileno(), socket.AF_UNIX, socket.SOCK_STREAM
    ).getsockopt(socket.SOL_SOCKET, socket.SO_PEERCRED, struct.calcsize("3i"))
    _pid, uid, _gid = struct.unpack("3i", raw)
    # uid 0 is root's own pinentry. Other system accounts are rejected.
    if uid != 0 and uid < 1000:
        return None
    try:
        return pwd.getpwuid(uid).pw_name
    except KeyError:
        return None


def main():
    try:
        user = peer_user()
    except OSError:
        user = None
    ok = False
    if user:
        env = os.environ.copy()
        env["PATH"] = HOWDY_BIN + os.pathsep + env.get("PATH", "")
        proc = subprocess.run(
            [PYTHON, COMPARE, user],
            stdout=sys.stderr,
            stderr=subprocess.STDOUT,
            env=env,
        )
        ok = proc.returncode == 0
    sys.stdout.write("OK\n" if ok else "FAIL\n")
    sys.stdout.flush()


if __name__ == "__main__":
    main()
