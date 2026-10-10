#!/usr/bin/env python3
# pinentry for gpg-agent, shaped like Windows Hello pinentry:
# on GETPIN, if this keygrip has an org.freedesktop.secrets item and the
# collection is already unlocked, run Howdy once and return that secret.
# Otherwise forward the prompt to the normal pinentry. Agent cache TTL is
# left untouched, so a hit never reaches this program.

import os
import socket
import subprocess
import sys

SCHEMA = os.environ.get("PINENTRY_HOWDY_SCHEMA", "org.nixos-home.pinentry-howdy")
SOCK = os.environ.get("PINENTRY_HOWDY_SOCK", "/run/pinentry-howdy/compare.sock")
ROOT_BUS = os.environ.get("PINENTRY_HOWDY_ROOT_BUS", "/run/pinentry-howdy/root.bus")
BUSCTL = os.environ.get("PINENTRY_HOWDY_BUSCTL", "@busctl@")
SECRET_TOOL = os.environ.get("PINENTRY_HOWDY_SECRET_TOOL", "@secretTool@")
PINENTRY_QT = "@pinentryQt@"
PINENTRY_CURSES = "@pinentryCurses@"
ERR_CANCELED = b"ERR 83886179 Operation cancelled\n"


def session_env():
    env = os.environ.copy()
    # Root keeps its own passphrase. Ignore a bus address inherited from
    # another user's session (sudo -E, a leftover graphical bus, ...).
    if os.geteuid() == 0:
        if os.path.exists(ROOT_BUS):
            env["DBUS_SESSION_BUS_ADDRESS"] = f"unix:path={ROOT_BUS}"
            env["HOME"] = "/root"
            return env
        return None
    if env.get("DBUS_SESSION_BUS_ADDRESS"):
        return env
    bus = f"/run/user/{os.getuid()}/bus"
    if os.path.exists(bus):
        env["DBUS_SESSION_BUS_ADDRESS"] = f"unix:path={bus}"
        return env
    return None


def assuan_escape(data: bytes) -> bytes:
    out = bytearray()
    for byte in data:
        if byte < 0x20 or byte == 0x7F or byte == ord("%"):
            out.extend(f"%{byte:02X}".encode("ascii"))
        else:
            out.append(byte)
    return bytes(out)


def choose_fallback():
    override = os.environ.get("PINENTRY_HOWDY_FALLBACK")
    if override:
        return [override]
    # gpg-agent often has no DISPLAY of its own. A graphical login still has
    # /run/user/<uid>, and that is the case this pinentry is installed for.
    if os.environ.get("PINENTRY_HOWDY_CURSES") == "1":
        return [PINENTRY_CURSES]
    if (
        os.environ.get("WAYLAND_DISPLAY")
        or os.environ.get("DISPLAY")
        or os.path.isdir(f"/run/user/{os.getuid()}")
    ):
        return [PINENTRY_QT]
    return [PINENTRY_CURSES]


def start_child():
    try:
        proc = subprocess.Popen(
            choose_fallback(),
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
        )
    except OSError:
        return None
    greet = proc.stdout.readline()
    if not greet.startswith(b"OK"):
        proc.kill()
        return None
    return proc


def read_reply(stream):
    lines = []
    while True:
        line = stream.readline()
        if not line:
            break
        lines.append(line)
        if line.startswith((b"OK", b"ERR", b"INQUIRE")):
            break
    return lines


def forward(child, line: bytes):
    child.stdin.write(line)
    child.stdin.flush()
    return read_reply(child.stdout)


def write_out(chunks):
    sys.stdout.buffer.write(b"".join(chunks))
    sys.stdout.buffer.flush()


def keygrip_of(line: bytes):
    arg = line.split(b" ", 1)[1].strip().decode("ascii", "replace")
    if len(arg) >= 3 and arg[1] == "/":
        arg = arg[2:]
    return arg.upper()


def item_unlocked(env, keygrip: str) -> bool:
    if env is None or not keygrip:
        return False
    try:
        out = subprocess.check_output(
            [
                BUSCTL, "--user", "call",
                "org.freedesktop.secrets",
                "/org/freedesktop/secrets",
                "org.freedesktop.Secret.Service",
                "SearchItems",
                "a{ss}", "2",
                "xdg:schema", SCHEMA,
                "keygrip", keygrip,
            ],
            env=env,
            stderr=subprocess.DEVNULL,
            timeout=5,
        )
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, OSError):
        return False
    # busctl prints one signature for both result arrays: "aoao <unlocked-count> ..."
    # Older tests and some versions print "ao <count> ao <count>".
    parts = out.split()
    if len(parts) < 2 or parts[0] not in (b"ao", b"aoao"):
        return False
    try:
        return int(parts[1]) > 0
    except ValueError:
        return False


def face_ok() -> bool:
    try:
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.settimeout(20)
        sock.connect(SOCK)
        data = b""
        while b"\n" not in data:
            chunk = sock.recv(64)
            if not chunk:
                break
            data += chunk
        sock.close()
    except OSError:
        return False
    return data.startswith(b"OK")


def lookup_secret(env, keygrip: str):
    try:
        out = subprocess.check_output(
            [
                SECRET_TOOL, "lookup",
                "xdg:schema", SCHEMA,
                "keygrip", keygrip,
            ],
            env=env,
            stderr=subprocess.DEVNULL,
            timeout=5,
        )
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, OSError):
        return None
    if out.endswith(b"\n"):
        out = out[:-1]
    if not out:
        return None
    return out


def try_face(env, keygrip: str):
    if not item_unlocked(env, keygrip):
        return None
    if not face_ok():
        return None
    return lookup_secret(env, keygrip)


def main():
    child = start_child()
    sys.stdout.buffer.write(b"OK Pleased to meet you\n")
    sys.stdout.buffer.flush()
    env = session_env()
    keygrip = ""

    while True:
        line = sys.stdin.buffer.readline()
        if not line:
            break
        cmd = line.strip()
        if cmd.startswith(b"SETKEYINFO ") and b" " in cmd:
            keygrip = keygrip_of(cmd)

        if cmd == b"GETPIN" and child is not None:
            secret = try_face(env, keygrip)
            if secret is not None:
                write_out([b"D ", assuan_escape(secret), b"\nOK\n"])
                continue

        if child is None:
            write_out([ERR_CANCELED])
            if cmd == b"BYE":
                break
            continue

        reply = forward(child, line if line.endswith(b"\n") else line + b"\n")
        if not reply:
            write_out([ERR_CANCELED])
            break
        write_out(reply)
        if cmd == b"BYE":
            break


if __name__ == "__main__":
    main()
