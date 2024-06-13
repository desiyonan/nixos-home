{ pkgs,  ... }:

{
  environment.systemPackages = [
    pkgs.jdk8
    # pkgs.jdk8_headless
    pkgs.jdk11
    # pkgs.jdk11_headless
    pkgs.maven
  ];

 programs.java = {
    enable = true;
    package = pkgs.jdk8;
  };
}
