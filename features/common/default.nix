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

    ../packages/vscode.nix
    ../packages/openssh.nix
  ];
  programs.ssh.askPassword = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";

  environment.systemPackages = with pkgs; [
    appimage-run
    appimagekit
    anydesk
    bind
    direnv
    docker-client
    dhcp
    fzf
    # fcitx-configtool
    # fcitx5
    # fcitx5-chinese-addons
    fcitx5-configtool
    fcitx5-m17n
    # fcitx5-pinyin-zhwiki
    # fcitx5-pinyin-moegirl
    # fcitx5-with-addons
    fcitx5-gtk
    firefox
    flameshot
    gcc
    glibc
    git
    gh
    go
    google-chrome
    gnome.gnome-keyring
    jdk8
    jdk11
    jetbrains.idea-ultimate
    latte-dock
    ntfs3g

    libsForQt5.fcitx5-qt
    libsForQt5.krdc
    libsForQt5.qt5.qtwayland

    htop
    hugo
    nix-index
    p7zip
    pciutils
    refind
    tree
    # termius
    #softmaker-office #收费不好用
    unar
    vim
    wget
  ];
}
