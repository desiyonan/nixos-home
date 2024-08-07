{ config, pkgs, lib, system, ... }:
with lib;

let
  cfg = config.features;
  common = import ./common;
  container = import ./container;
  dev = import ./dev;
  sys = import ./system;
  modules = lib.listModules ./.;
in {
  options.features = {
    enable = mkOption {
      description = "Enable features";
      type = types.bool;
      default = true;
    };
    includes = mkOption {
      description = "Include features";
      type = with types; listOf string;
      default = [];
    };
    excludes = mkOption {
      description = "Exclude features";
      type = with types; listOf string;
      default = [];
    };
  };

  imports = [
    common
    # container
    # dev
    # sys
    # ./cloud
  ] ++ modules;

  # config = mkIf(cfg.enable) {
  #   environment.systemPackages = with mpkgs; [
  #     mpkgs.wechat-uos
  #   ];
  # };
}
