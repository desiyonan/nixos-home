{ pkgs, mpkgs, ... }:

{

  environment.systemPackages = with pkgs;[
    nodejs
  ];

}
