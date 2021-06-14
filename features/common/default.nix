{ pkgs, ... }:

{
  imports = [
    ./nix-features.nix
    ./fonts.nix
    ./location.nix
    ./passwordstore.nix
    ./plasma5.nix
    ./resolved.nix
    ./vscode.nix
    # ./zerotierone.nix
  ];

  environment.systemPackages = with pkgs; [
    direnv
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    firefox
    git

    bind

    fzf
    fcitx-configtool
    flameshot
    gcc
    htop
    nix-index
    refind
  ];
}
