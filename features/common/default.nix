{ pkgs, mpkgs, modulesPath, ... }:

{
  imports = [
    ./display.nix
    ./fonts.nix
    ./hardware.nix
    # ./im.nix
    ./network.nix
    ./nix-features.nix
    ./passwordstore.nix
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
    # latte-dock
    ntfs3g

    egl-wayland
    libsForQt5.krdc
    libsForQt5.qt5.qtbase
    libsForQt5.qt5.qtwayland
    libsForQt5.qtstyleplugins
    inetutils
    jq

    htop
    hugo
    httpie
    hexyl

    kate
    mutt
    mcfly
    nix-index
    netease-cloud-music-gtk
    p7zip
    pciutils
    procs

    refind
    tree
    tmux
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
    # (mpkgs.latte-dock)
    (mpkgs.qv2ray-full)
  ];

  environment = {
    variables = {
      DOCKER_HOST = "dk.dnfn.tech:5732";
    };
    sessionVariables = {
      DOCKER_HOST = "dk.dnfn.tech:5732";
    };
  };
}
