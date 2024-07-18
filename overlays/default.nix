{ nixpkgs, lib, inputs, ... }:

{
  # nixpkgs.overlays = lib.listModules ./.;

  nixpkgs.overlays = [
    (import ./mesh.nix {inherit nixpkgs;})
    (import ./unstable.nix {inherit nixpkgs inputs;})
    (import ./pkgs.nix {inherit nixpkgs;})
    (import ./rust-rover.nix {inherit nixpkgs inputs;})
    (import ./vscode.nix {inherit nixpkgs;})
    (import ./latte-dock.nix {inherit nixpkgs;})
  ];
}
