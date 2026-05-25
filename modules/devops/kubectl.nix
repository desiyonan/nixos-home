{ config, lib, pkgs, ... }:

let
  cfg = config.modules.devops;
in
{
  config = lib.mkIf (cfg.enable && cfg.kubectl.enable) {
    environment.systemPackages = [ pkgs.kubectl ];
  };
}
