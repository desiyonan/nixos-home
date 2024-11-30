{ pkgs,  ... }:

{
  environment.systemPackages = [
    pkgs.jdk17
    pkgs.jdk11
    pkgs.jdk8
    # pkgs.maven
    pkgs.liquibase
  ];

  programs.java = {
    enable = true;
    package = pkgs.jdk11;
  };
}
