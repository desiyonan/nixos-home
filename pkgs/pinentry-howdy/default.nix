{
  stdenvNoCC,
  lib,
  howdy,
  libsecret,
  systemd,
  pinentry-qt,
  pinentry-curses,
  python3,
  dbus,
  gnome-keyring,
  gawk,
}:

let
  pythonDbus = python3.withPackages (ps: [ ps."dbus-python" ]);
in

stdenvNoCC.mkDerivation {
  pname = "pinentry-howdy";
  version = "0.1.0";

  src = ./.;

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    howdyPython=$(${gawk}/bin/awk 'NR==3 { print $1; exit }' ${howdy}/bin/.howdy-wrapped)
    test -x "$howdyPython"
    test -f ${howdy}/lib/howdy/compare.py

    substitute() {
      sed \
        -e "1s|^#!.*|#!${python3}/bin/python3|" \
        -e "s|@busctl@|${systemd}/bin/busctl|g" \
        -e "s|@secretTool@|${libsecret}/bin/secret-tool|g" \
        -e "s|@pinentryQt@|${pinentry-qt}/bin/pinentry-qt|g" \
        -e "s|@pinentryCurses@|${pinentry-curses}/bin/pinentry-curses|g" \
        -e "s|@howdyPython@|$howdyPython|g" \
        -e "s|@comparePy@|${howdy}/lib/howdy/compare.py|g" \
        -e "s|@howdyBin@|${howdy}/bin|g" \
        -e "s|@dbusDaemon@|${dbus}/bin/dbus-daemon|g" \
        -e "s|@gnomeKeyring@|${gnome-keyring}/bin/gnome-keyring-daemon|g" \
        "$1" > "$2"
      chmod 0755 "$2"
    }

    mkdir -p bin libexec
    substitute pinentry.py bin/pinentry
    substitute compare-helper.py libexec/pinentry-howdy-compare
    substitute enroll.py bin/pinentry-howdy-enroll
    sed \
      -e "1s|^#!.*|#!${pythonDbus}/bin/python3|" \
      -e "s|@dbusDaemon@|${dbus}/bin/dbus-daemon|g" \
      -e "s|@gnomeKeyring@|${gnome-keyring}/bin/gnome-keyring-daemon|g" \
      secrets-service.py > libexec/pinentry-howdy-secrets
    chmod 0755 libexec/pinentry-howdy-secrets
    runHook postBuild
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck
    ${python3}/bin/python3 ${./tests/test_protocol.py} "$PWD/bin/pinentry"
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/libexec $out/lib/systemd/system
    cp -a bin/. $out/bin/
    cp -a libexec/. $out/libexec/
    sed "s|@compare@|$out/libexec/pinentry-howdy-compare|g" \
      pinentry-howdy@.service > $out/lib/systemd/system/pinentry-howdy@.service
    sed "s|@secrets@|$out/libexec/pinentry-howdy-secrets|g" \
      pinentry-howdy-secrets.service > $out/lib/systemd/system/pinentry-howdy-secrets.service
    cp pinentry-howdy.socket $out/lib/systemd/system/pinentry-howdy.socket
    runHook postInstall
  '';

  meta = {
    description = "Pinentry that unlocks an enrolled GPG keygrip with Howdy and org.freedesktop.secrets";
    mainProgram = "pinentry";
    platforms = lib.platforms.linux;
  };
}
