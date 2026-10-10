{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  python3,
  buildFHSEnv,
  writeShellScript,
  makeWrapper,
}:

# 向日葵 Linux 个人版现以 AweSun 发行。二进制写死 /usr/local/awesun，
# 安装时改成 FHS 能挂上的 /opt/awesun。
let
  version = "16.6.0.32198";

  unwrapped = stdenv.mkDerivation {
    pname = "sunlogin-unwrapped";
    inherit version;

    src = fetchurl {
      url = "https://dw.oray.com/sl/linux/awesun_${version}_amd64.deb";
      hash = "sha256-dtLVNEE6WKi79cV3teYXjj6vimhTBMAnrwL6TpItVjk=";
    };

    nativeBuildInputs = [
      dpkg
      python3
    ];

    unpackPhase = ''
      runHook preUnpack
      dpkg-deb -x "$src" .
      runHook postUnpack
    '';

    dontBuild = true;

    # FHS 只合并 bin/lib/share/opt。二进制写死 /usr/local/awesun，改成 /opt/awesun，短出来的字节用空字符补上。
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/opt"
      cp -a usr/local/awesun "$out/opt/awesun"
      chmod -R u+w "$out/opt/awesun"
      python3 - <<'PY'
      import os
      root = os.environ["out"] + "/opt/awesun"
      old = b"/usr/local/awesun"
      new = b"/opt/awesun"
      pad = new + b"\0" * (len(old) - len(new))
      for dirpath, _, files in os.walk(root):
          for name in files:
              path = os.path.join(dirpath, name)
              with open(path, "rb") as f:
                  data = f.read()
              if old not in data:
                  continue
              with open(path, "wb") as f:
                  f.write(data.replace(old, pad))
      PY
      mkdir -p "$out/share/applications" "$out/share/icons/hicolor/128x128/apps"
      cp "$out/opt/awesun/awesun.png" "$out/share/icons/hicolor/128x128/apps/awesun.png"
      # 客户端会把这份 desktop 复制到用户目录，Exec 走 PATH 里的 sunlogin 包装脚本。
      cat > "$out/share/applications/awesun.desktop" <<EOF
      [Desktop Entry]
      Name=向日葵远程控制
      Name[en]=AweSun
      GenericName=向日葵远程控制
      Comment=远程控制本机或其他设备
      Exec=sunlogin
      Icon=awesun
      Terminal=false
      Type=Application
      Categories=Network;
      StartupNotify=false
      EOF
      runHook postInstall
    '';
  };

  entry = writeShellScript "sunlogin-entry" ''
    set -euo pipefail
    cmd="''${1:-gui}"
    case "$cmd" in
      daemon)
        shift
        exec /opt/awesun/bin/awesun_daemon "$@"
        ;;
      gui)
        if [[ $# -gt 0 ]]; then
          shift
        fi
        exec /opt/awesun/awesun "$@"
        ;;
      *)
        exec /opt/awesun/awesun "$@"
        ;;
    esac
  '';
in
buildFHSEnv {
  pname = "sunlogin";
  inherit version;
  runScript = entry;

  targetPkgs = pkgs: [
    unwrapped
    pkgs.bash
    pkgs.coreutils
    pkgs.glib
    pkgs.gtk3
    pkgs.fontconfig
    pkgs.webkitgtk_4_1
    pkgs.libappindicator-gtk3
    pkgs.libnotify
    pkgs.libepoxy
    pkgs.libxcrypt
    pkgs.libxcrypt-legacy
    pkgs.util-linux
    pkgs.zlib
    pkgs.libx11
    pkgs.libxfixes
    pkgs.libxrandr
    pkgs.libxext
    pkgs.libxi
    pkgs.libxtst
    pkgs.libxrender
    pkgs.libxcursor
    pkgs.libxinerama
    pkgs.libice
    pkgs.libsm
    pkgs.libxcb
    pkgs.libxkbcommon
    pkgs.xhost
    pkgs.pango
    pkgs.cairo
    pkgs.gdk-pixbuf
    pkgs.atk
    pkgs.at-spi2-atk
    pkgs.at-spi2-core
    pkgs.dbus
    pkgs.libGL
    pkgs.libdrm
    pkgs.alsa-lib
    pkgs.pulseaudio
    pkgs.libsecret
    pkgs.stdenv.cc.cc
  ];

  # 服务会 cp desktop 到 /etc/xdg/autostart。FHS 把该目录只读挂上，cp 报只读文件系统。
  extraBwrapArgs = [
    "--tmpfs /etc/xdg/autostart"
  ];

  nativeBuildInputs = [ makeWrapper ];

  extraInstallCommands = ''
    ln -s "$out/bin/sunlogin" "$out/bin/awesun"
    makeWrapper "$out/bin/sunlogin" "$out/bin/awesun-daemon" \
      --add-flags daemon \
      --add-flags -m \
      --add-flags server \
      --add-flags -name \
      --add-flags awesun

    mkdir -p \
      "$out/share/applications" \
      "$out/share/icons/hicolor/128x128/apps" \
      "$out/lib/systemd/system"

    cp "${unwrapped}/opt/awesun/awesun.png" \
      "$out/share/icons/hicolor/128x128/apps/awesun.png"

    cat > "$out/share/applications/awesun.desktop" <<EOF
    [Desktop Entry]
    Name=向日葵远程控制
    Name[en]=AweSun
    GenericName=向日葵远程控制
    Comment=远程控制本机或其他设备
    Exec=$out/bin/sunlogin
    Icon=awesun
    Terminal=false
    Type=Application
    Categories=Network;
    StartupNotify=false
    EOF

    cat > "$out/lib/systemd/system/awesun.service" <<EOF
    [Unit]
    Description=AweSun / 向日葵远程控制
    After=network-online.target
    Wants=network-online.target

    [Service]
    Type=simple
    LogsDirectory=awesun
    ExecStart=$out/bin/awesun-daemon
    Restart=always
    RestartSec=5
    KillMode=control-group

    [Install]
    WantedBy=multi-user.target
    EOF
  '';

  passthru = {
    inherit unwrapped;
  };

  meta = {
    description = "向日葵远程控制（AweSun Linux 个人版）";
    homepage = "https://sunlogin.oray.com";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "sunlogin";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
