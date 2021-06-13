{ pkgs, ... }:

{
  imports = [
    ./nix-features.nix
    ./location.nix
    ./passwordstore.nix
    ./plasma5.nix
    ./resolved.nix
    ./vscode.nix
    # ./zerotierone.nix
  ];

  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    firefox
    git
  ];
}
