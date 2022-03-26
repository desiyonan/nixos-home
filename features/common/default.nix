{ pkgs, mpkgs, modulesPath, ... }:

{
  imports = [
    ./display.nix
    ./fonts.nix
    ./hardware.nix
    ./im.nix
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
    direnv
    docker-client
    dhcp
    firefox
    flameshot
    fzf
    gcc
    glibc
    go
    google-chrome
    gnome.gnome-keyring
    # latte-dock
    (mpkgs.latte-dock)
    ntfs3g

    egl-wayland
    libsForQt5.krdc
    libsForQt5.qt5.qtbase
    libsForQt5.qt5.qtwayland
    libsForQt5.qtstyleplugins

    htop
    hugo
    kate
    mutt
    nix-index
    netease-cloud-music-gtk
    p7zip
    pciutils
    refind
    tree
    tmux
    # termius
    #softmaker-office #收费不好用
    unar
    vim
    vivaldi
    vivaldi-ffmpeg-codecs
    wget
    wpsoffice
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
