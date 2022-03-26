{ pkgs, ... }:

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

    ../env/dev.nix
    ../packages/vscode.nix
    ../packages/openssh.nix
  ];
  programs.ssh.askPassword = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";

  environment.systemPackages = with pkgs; [
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
    git
    gh
    go
    google-chrome
    gnome.gnome-keyring
    latte-dock
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
}
