{ config, lib, pkgs, ... }:

let
  cfg = config.modules.develop;
in
{
  config = lib.mkIf (cfg.enable && cfg.java.enable) {
    environment.systemPackages = with pkgs; [
      jdk21
      jdk17
      jdk11
      jdk8
      jetbrains.idea
      maven
      gradle
      checkstyle
      pmd
      sonar-scanner-cli
      openapi-generator-cli
      spotbugs
    ];

    programs.java = {
      enable = true;
      package = pkgs.jdk17;
    };

    environment.variables = {
      JAVA_HOME = pkgs.jdk17.home;
      JDK8_HOME = pkgs.jdk8.home;
      JDK11_HOME = pkgs.jdk11.home;
      JDK17_HOME = pkgs.jdk17.home;
      JDK21_HOME = pkgs.jdk21.home;
    };
    environment.sessionVariables = {
      JAVA_HOME = pkgs.jdk17.home;
    };
  };
}
