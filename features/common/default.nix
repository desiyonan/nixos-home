{ pkgs, mpkgs, modulesPath, ... }:

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

    ../env/dev.nix
  ];

  environment.systemPackages =  with pkgs; [
    ark
    appimage-run
    appimagekit
    anydesk
    bash
    bind
    bat

    direnv
    docker-client
    dhcp
    dog
    duf

    firefox
    flameshot
    fzf
    fd
    fx

    gcc
    glibc
    go
    google-chrome
    gnome.gnome-keyring
    ntfs3g

    # libsForQt5.full
    # libsForQt5.qt5.qttools
    # libsForQt5.krdc
    inetutils
    jq

    htop
    hugo
    httpie
    hexyl

    kate
    kdiff3
    kompare
    mutt
    mcfly
    nix-index
    netease-cloud-music-gtk
    p7zip
    pciutils
    procs

    rustup
    refind

    tree
    tmux
    thunderbird
    # termius
    #softmaker-office #收费不好用
    unar
    vim
    # vivaldi
    # vivaldi-ffmpeg-codecs
    wget
    wpsoffice
    xournal

    latte-dock
    # mpkgs.latte-dock
    # mpkgs.qv2ray-full
    # mpkgs.wechat-uos
    # mpkgs.netease-cloud-music
  ];

  environment = {
    variables = {
      DOCKER_HOST = "dk.dnfn.tech:5732";
      QT_DEBUG_PLUGINS= "1";
      # QT_QPA_PLATFORMTHEME="qt5ct";
      # QT_QPA_PLATFORM="wayland";
    };
    sessionVariables = {
      DOCKER_HOST = "dk.dnfn.tech:5732";
      QT_DEBUG_PLUGINS= "1";
      # QT_QPA_PLATFORMTHEME="qt5ct";
      # QT_QPA_PLATFORM="wayland";
    };
  };
}
