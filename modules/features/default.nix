{ config, pkgs, mpkgs, lib, ... }:
with lib;

let
  cfg = config.features;
  common = import ./common;
  container = import ./container;
  dev = import ./dev;
  system = import ./system;
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
    container
    dev
    system
  ] ;
#    if cfg.enable then [
        # common
        # container
        # dev
    # ] 
#   else
    # [];


  config = mkIf(cfg.enable) {
    environment.systemPackages = with mpkgs; [
    
    ];
  };
}
