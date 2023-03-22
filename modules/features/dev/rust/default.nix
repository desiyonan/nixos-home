{ pkgs, mpkgs, ... }:

{

  environment.systemPackages = with pkgs;[
    cargo
    rustup
  ];

}
