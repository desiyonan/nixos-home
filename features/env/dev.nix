{ pkgs, mpkgs, ... }:

{
  environment.systemPackages = [
    pkgs.jdk8
    pkgs.jdk11
    pkgs.maven
    pkgs.git
    pkgs.gh
    pkgs.vscode
  ];

}
