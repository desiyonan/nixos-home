{ pkgs, ... }:

{
  imports = [
    ./display.nix
    ./fonts.nix
    ./hardware.nix
    ./im.nix
    ./network.nix
    ./nix-features.nix
    ./shell.nix
    ./zone.nix

    ./openssh.nix
    ./gpg.nix
    # ../env/dev.nix
    ./multimedia.nix
    ./tailscale.nix
  ];

  environment.systemPackages =  with pkgs; [
    ark
    appimage-run
    appimagekit
    anydesk
    # adb-sync-unstable
    adbfs-rootless
    android-tools

    bzip2
    bash
    bind
    bat
    blender
    conda

    gnumake
    cmake
    clang
    du-dust

    dbeaver-bin

    lightworks
    lsof
    lshw
    llvmPackages.clangUseLLVM
    llvmPackages.libclang

    direnv
    iptables
    nix-direnv
    # docker-client
    # dhcp
    dog
    duf

    envsubst
    # firefox
    filelight
    flameshot
    fzf
    fd
    fx

    git-lfs
    gcc
    glibc
    # google-chrome
    # gnome.gnome-keyring
    ntfs3g

    # libsForQt5.full
    # libsForQt5.qt5.qttools
    # libsForQt5.krdc
    openiscsi
    inetutils
    jq

    htop
    hugo
    httpie
    hexyl

    kdiff3
    kompare

    mutt
    mcfly
    # musl

    ncdu
    nix-index
    # netease-cloud-music-gtk
    qcm
    # waylyrics
    yesplaymusic
    freerdp3

    obs-studio
    opencv
    openssl
    pkg-config

    p7zip
    pciutils
    procs
    pipewire
    # pipewire-media-session
    # wireplumber
    wechat-uos

    redli
    refind

    scrcpy
    sops

    tree
    tmux
    thunderbird
    thunderbolt
    kdePackages.plasma-thunderbolt
    bolt

    tailscale
    # termius
    #softmaker-office #收费不好用
    unar
    vim
    wget
    wpsoffice
    xournal
    vlc
    waveterm
    warp-terminal
    webcat


    zip
    # llvm
    # libclang
    # latte-dock
    # mpkgs.latte-dock
    # mpkgs.qv2ray-full
    qv2ray-full
    clash-meta
    # mpkgs.wechat-uos
    # mpkgs.netease-cloud-music

    envsubst
    gdb
    gImageReader
    redli
    scrcpy
    tesseract
    vlc
    # umbrello
    drawio
    android-tools
    adbfs-rootless
    # adb-sync-unstable
    # emulator
    normcap
    patchelf
    todoist-electron
    linux-wifi-hotspot
  ];

  environment = {
    variables = {
      # DOCKER_HOST = "dk.dnfn.tech:5732";
      # QT_DEBUG_PLUGINS= "1";
      # LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
      # QT_QPA_PLATFORMTHEME="qt5ct";
      # QT_QPA_PLATFORM="wayland";
    };
    sessionVariables = {
      # DOCKER_HOST = "dk.dnfn.tech:5732";
      # QT_DEBUG_PLUGINS= "1";
      # LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
      # QT_QPA_PLATFORMTHEME="qt5ct";
      # QT_QPA_PLATFORM="wayland";
    };
  };
  services.openiscsi = {
    enable = false;
    name = "iqn.2020-08.org.linux-iscsi.initiatorhost:ws";
  };
  services.fwupd.enable = true;
  services.hardware.bolt.enable = true;
}
