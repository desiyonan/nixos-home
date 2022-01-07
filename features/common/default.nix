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
    ./vscode.nix
    ./zerotierone.nix
  ];

  environment.systemPackages = with pkgs; [
    appimage-run
    appimagekit
    anydesk
    bind
    direnv
    docker-client
    fzf
    fcitx-configtool
    firefox
    flameshot
    gcc
    git
    gh
    go
    gnome.gnome-keyring
    jdk8
    jdk11
    jetbrains.idea-ultimate
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
