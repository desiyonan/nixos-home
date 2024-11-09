{ pkgs,  ... }:

{
  environment.systemPackages = [
    # pkgs.jdk17
    # pkgs.jdk8
    # pkgs.jdk8_headless
    # pkgs.jdk11
    # pkgs.jdk11_headless
    # pkgs.maven
    pkgs.liquibase
  ];

  programs.java = {
    enable = true;
    package = pkgs.jdk17;
  };
}
