#!/usr/bin/env python3
# Root's own org.freedesktop.secrets. A private session bus at
# /run/pinentry-howdy/root.bus (mode 0600) and a login keyring under /root.
# The keyring master password is empty so this service can open it without a
# GUI prompter; the GPG passphrases inside are root's, and the socket mode is
# what keeps other users out. This process does not change uid.

import os
import pwd
import signal
import socket
import subprocess
import sys
import time

import dbus

BUS = os.environ.get("PINENTRY_HOWDY_ROOT_BUS", "/run/pinentry-howdy/root.bus")
HOME = os.environ.get("PINENTRY_HOWDY_ROOT_HOME", "/root")
DBUS_DAEMON = "@dbusDaemon@"
GNOME_KEYRING = "@gnomeKeyring@"
COLLECTION = "/org/freedesktop/secrets/collection/login"
SERVICE = "org.freedesktop.secrets"


def write_config(path, bus):
    text = f"""<!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN" "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
<busconfig>
  <type>session</type>
  <listen>unix:path={bus}</listen>
  <auth>EXTERNAL</auth>
  <policy context="default">
    <allow send_destination="*" eavesdrop="true"/>
    <allow eavesdrop="true"/>
    <allow own="*"/>
  </policy>
</busconfig>
"""
    with open(path, "w") as handle:
        handle.write(text)
    os.chmod(path, 0o600)


def notify_ready():
    addr = os.environ.get("NOTIFY_SOCKET")
    if not addr:
        return
    if addr.startswith("@"):
        addr = "\0" + addr[1:]
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
    try:
        sock.sendto(b"READY=1\n", addr)
    finally:
        sock.close()


def plain_secret(service):
    _output, session = service.OpenSession(
        "plain",
        dbus.String("", variant_level=1),
        dbus_interface="org.freedesktop.Secret.Service",
    )
    return dbus.Struct(
        (
            dbus.ObjectPath(session),
            dbus.ByteArray(b""),
            dbus.ByteArray(b""),
            dbus.String("text/plain"),
        ),
        signature="oayays",
    )


def ensure_collection():
    os.environ["DBUS_SESSION_BUS_ADDRESS"] = f"unix:path={BUS}"
    deadline = time.time() + 15
    last = None
    while time.time() < deadline:
        try:
            bus = dbus.SessionBus()
            if not bus.name_has_owner(SERVICE):
                time.sleep(0.2)
                continue
            service = bus.get_object(SERVICE, "/org/freedesktop/secrets")
            try:
                collection = bus.get_object(SERVICE, COLLECTION)
                locked = collection.Get(
                    "org.freedesktop.Secret.Collection",
                    "Locked",
                    dbus_interface="org.freedesktop.DBus.Properties",
                )
            except dbus.exceptions.DBusException as exc:
                last = exc
                secret = plain_secret(service)
                props = dbus.Dictionary(
                    {"org.freedesktop.Secret.Collection.Label": "login"},
                    signature="sv",
                )
                service.CreateWithMasterPassword(
                    props,
                    secret,
                    dbus_interface="org.gnome.keyring.InternalUnsupportedGuiltRiddenInterface",
                )
                return
            if locked:
                service.UnlockWithMasterPassword(
                    dbus.ObjectPath(COLLECTION),
                    plain_secret(service),
                    dbus_interface="org.gnome.keyring.InternalUnsupportedGuiltRiddenInterface",
                )
            return
        except dbus.exceptions.DBusException as exc:
            last = exc
            time.sleep(0.2)
    sys.stderr.write(f"root Secret Service did not become usable: {last}\n")
    sys.exit(1)


def stop(children):
    for proc in children:
        if proc.poll() is None:
            proc.terminate()
    for proc in children:
        try:
            proc.wait(timeout=3)
        except subprocess.TimeoutExpired:
            proc.kill()


def main():
    account = pwd.getpwuid(os.geteuid())
    runtime = os.path.dirname(BUS)
    os.makedirs(runtime, mode=0o750, exist_ok=True)
    os.makedirs(HOME, mode=0o700, exist_ok=True)
    os.umask(0o077)
    if os.path.exists(BUS):
        os.unlink(BUS)
    config = os.path.join(runtime, "session.conf")
    write_config(config, BUS)

    env = os.environ.copy()
    env["HOME"] = HOME
    env["USER"] = account.pw_name
    env["LOGNAME"] = account.pw_name
    env["XDG_RUNTIME_DIR"] = runtime
    env["DBUS_SESSION_BUS_ADDRESS"] = f"unix:path={BUS}"

    children = []

    def on_signal(_signum, _frame):
        stop(children)
        sys.exit(0)

    signal.signal(signal.SIGTERM, on_signal)
    signal.signal(signal.SIGINT, on_signal)

    dbus_proc = subprocess.Popen(
        [DBUS_DAEMON, "--config-file", config, "--nofork", "--nopidfile"],
        env=env,
    )
    children.append(dbus_proc)
    deadline = time.time() + 5
    while not os.path.exists(BUS):
        if dbus_proc.poll() is not None or time.time() > deadline:
            stop(children)
            sys.exit(1)
        time.sleep(0.05)
    os.chmod(BUS, 0o600)

    keyring = subprocess.Popen(
        [GNOME_KEYRING, "--foreground", "--components=secrets"],
        env=env,
    )
    children.append(keyring)
    try:
        ensure_collection()
        notify_ready()
        while True:
            if dbus_proc.poll() is not None or keyring.poll() is not None:
                sys.exit(1)
            time.sleep(0.5)
    finally:
        stop(children)


if __name__ == "__main__":
    main()
