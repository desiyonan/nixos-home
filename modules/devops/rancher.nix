{ config, lib, pkgs, ... }:

let
  cfg = config.modules.devops;
in
{
  config = lib.mkIf (cfg.enable && cfg.rancher.enable) {
    environment.systemPackages = [ pkgs.rancher ];
  };
}
