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
    # ./zerotierone.nix
  ];

  environment.systemPackages = with pkgs; [
    appimage-run
    appimagekit
    bind
    direnv
    fzf
    fcitx-configtool
    firefox
    flameshot
    gcc
    git
    gh
    htop
    nix-index
    p7zip
    refind
    softmaker-office
    unar
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
  ];
}
