{
  lib, stdenv, fetchurl, dpkg, autoPatchelfHook, wrapGAppsHook3, makeWrapper,
  gobject-introspection,
  alsa-lib, at-spi2-atk, at-spi2-core, cairo, cups, dbus, expat, glib, gtk3,
  libdrm, libgbm, libGL, libnotify, libsecret, libx11, libxcb, libxcomposite,
  libxdamage, libxext, libxfixes, libxkbcommon, libxrandr, libxscrnsaver,
  libxtst, nspr, nss, pango, systemd, wayland, zlib,
  python3, xclip, xdotool, xorg-server, xdg-utils,
}:

let
  pname = "orca-ide";
  version = "1.4.245";
  python = python3.withPackages (ps: [ ps.pygobject3 ps.pycairo ]);
in
stdenv.mkDerivation {
  inherit pname version;

  # The deb provides the application directly, without an AppImage/FHS runtime.
  src = fetchurl {
    url = "https://github.com/stablyai/orca/releases/download/v${version}/orca-ide_${version}_amd64.deb";
    hash = "sha256-VEIOItSd2p32btTpQ7YoRMlV1P2dXBBZv493ArdgvIk=";
  };

  nativeBuildInputs = [
    dpkg autoPatchelfHook wrapGAppsHook3 makeWrapper gobject-introspection
  ];
  buildInputs = [
    alsa-lib at-spi2-atk at-spi2-core cairo cups dbus expat glib gtk3
    libdrm libgbm libnotify libsecret libx11 libxcb libxcomposite libxdamage
    libxext libxfixes libxkbcommon libxrandr libxscrnsaver libxtst
    nspr nss pango systemd wayland zlib stdenv.cc.cc.lib
  ];
  # ANGLE dlopens EGL from libGLESv2.so, so shared objects also need these paths.
  appendRunpaths = map (p: "${lib.getLib p}/lib") [ libGL libnotify libsecret wayland ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';
  dontConfigure = true;
  dontBuild = true;
  dontWrapGApps = true;

  # Remote deployment templates and foreign-platform tools must stay portable.
  # Patch only binaries used on this host; do not strip or rewrite remote payloads.
  dontAutoPatchelf = true;
  dontPatchELF = true;
  dontStrip = true;
  dontPatchShebangs = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib" "$out/bin"
    cp -a opt/Orca "$out/lib/orca-ide"
    chmod -R u+w "$out/lib/orca-ide"
    patchShebangs "$out/lib/orca-ide/resources/bin/orca-ide"
    ln -s "$out/lib/orca-ide/resources/bin/orca-ide" "$out/bin/orca-ide"

    # Retain the local desktop ID and keep the GUI separate from the CLI.
    install -Dm644 usr/share/applications/orca-ide.desktop \
      "$out/share/applications/Orca.desktop"
    substituteInPlace "$out/share/applications/Orca.desktop" \
      --replace-fail '/opt/Orca/orca-ide' "$out/bin/orca-ide-gui" \
      --replace-fail 'x-scheme-handler/orca;x-scheme-handler/orca;' 'x-scheme-handler/orca;'
    mkdir -p "$out/share/icons"
    cp -a usr/share/icons/hicolor "$out/share/icons/"
    runHook postInstall
  '';

  postFixup = ''
    autoPatchelf --no-recurse "$out/lib/orca-ide"
    autoPatchelf \
      "$out/lib/orca-ide/resources/agent-browser-linux-x64" \
      "$out/lib/orca-ide/resources/bin" \
      "$out/lib/orca-ide/resources/node_modules" \
      "$out/lib/orca-ide/resources/ripgrep/linux-x64"
    makeWrapper "$out/lib/orca-ide/orca-ide" "$out/bin/orca-ide-gui" \
      --prefix PATH : ${lib.makeBinPath [ python xclip xdotool xorg-server xdg-utils ]} \
      "''${gappsWrapperArgs[@]}"
  '';

  meta = {
    description = "Orca IDE for parallel agentic development";
    homepage = "https://github.com/stablyai/orca";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "orca-ide-gui";
  };
}
