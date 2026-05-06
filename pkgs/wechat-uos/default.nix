{
  stdenv,
  fetchurl,
  writeShellScript,
  steam,
  scrot,
  lib,
  makeWrapper,
  xdg-utils,
  runCommand,
}:

################################################################################
# Pulled from nixos-cn/flakes packages/wechat-uos, adapted for local use.
################################################################################

let
  version = "4.1.1.4";

  license = stdenv.mkDerivation {
    pname = "wechat-uos-license";
    version = "0.0.1";
    src = ./license.tar.gz;
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      mkdir -p $out
      cp -r etc var $out/
    '';
  };

  resource = stdenv.mkDerivation rec {
    pname = "wechat-uos-resource";
    inherit version;
    src = fetchurl {
      url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb";
      sha256 = "1qlpqw10x8nw3z3awi1hh1ibsx62rrp0530rn1m3sf1r30h5qsnf";
    };

    unpackPhase = ''
      ar x ${src}
    '';

    installPhase = ''
      mkdir -p $out
      data_tar="$(ls data.tar.* | head -n 1)"
      tar xf "$data_tar" -C $out
      mv $out/usr/* $out/
      rm -rf $out/usr
    '';
  };

  pureXDGOpen = lib.hiPrio (
    runCommand "xdg" { nativeBuildInputs = [ makeWrapper ]; } ''
      mkdir -p $out/bin
      makeWrapper ${xdg-utils}/bin/xdg-open $out/bin/xdg-open \
        --set LD_LIBRARY_PATH "" \
        --set LD_PRELOAD ""
    ''
  );

  steam-run = (steam.override {
    extraPkgs = p:
      [
        license
        resource
      ]
      ++ (with p; [
        cups
        alsa-lib
        at-spi2-atk
        at-spi2-core
        atk
        cairo
        dbus
        expat
        ffmpeg
        fontconfig
        freetype
        gdk-pixbuf
        glib
        gtk3
        krb5
        libGL
        libdrm
        libgbm
        libice
        libnotify
        libsm
        libuuid
        libva
        libx11
        libxcb
        libxcomposite
        libxcursor
        libxdamage
        libxext
        libxfixes
        libxft
        libxi
        libxrandr
        libxrender
        libxshmfence
        libxscrnsaver
        libxt
        libxtst
        libxml2
        libxcb-image
        libxcb-keysyms
        libxcb-render-util
        libxcb-wm
        nss
        nspr
        pango
        pulseaudio
        scrot
        stdenv.cc.cc
        stdenv.cc.libc
        systemd
        vulkan-loader
        wayland
        zlib
        pureXDGOpen
      ]);
  }).run;

  startScript = writeShellScript "wechat-uos" ''
    wechat_pid=$(pidof wechat-uos || true)
    if test -n "$wechat_pid"; then
      kill -9 "$wechat_pid"
    fi
    # WeChat screenshot fallback uses external scrot binary.
    export PATH="${scrot}/bin:${xdg-utils}/bin:$PATH"
    # Prefer Wayland backend so fcitx5 text-input works consistently.
    export QT_QPA_PLATFORM=wayland
    export QT_IM_MODULE=fcitx
    ${steam-run}/bin/steam-run \
      ${resource}/opt/wechat/wechat
  '';
in
stdenv.mkDerivation {
  pname = "wechat-uos";
  inherit version;
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin $out/share/applications
    ln -s ${startScript} $out/bin/wechat-uos
    ln -s ${./wechat-uos.desktop} $out/share/applications/wechat-uos.desktop
    ln -s ${resource}/share/icons $out/share/icons
  '';

  meta = with lib; {
    description = "WeChat desktop";
    homepage = "https://weixin.qq.com/";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfreeRedistributable;
    mainProgram = "wechat-uos";
  };
}
