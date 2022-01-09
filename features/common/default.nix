{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./nix-features.nix
    ./bash.nix
    ./fonts.nix
    ./location.nix
    ./passwordstore.nix
    ./plasma5.nix
    ./resolved.nix
    ./wayland.nix
    ./vscode.nix
    ./zerotierone.nix
  ];
  programs.ssh.askPassword = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";

  environment.systemPackages = with pkgs; [
    appimage-run
    appimagekit
    anydesk
    bind
    direnv
    docker-client
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
    git
    gh
    go
    google-chrome
    gnome.gnome-keyring
    jdk8
    jdk11
    jetbrains.idea-ultimate

    libsForQt5.fcitx5-qt
    libsForQt5.krdc

    htop
    hugo
    nix-index
    p7zip
    refind
    tree
    #softmaker-office #收费不好用
    unar
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
  ];
}
