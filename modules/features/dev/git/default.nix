{ pkgs, mpkgs, ... }:

{
  environment.systemPackages = [
    pkgs.git
    pkgs.gh
    pkgs.subversionClient
  ];

}
