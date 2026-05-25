{ config, lib, pkgs, ... }:

let
  cfg = config.modules.devops;
in
{
  config = lib.mkIf (cfg.enable && cfg.helm.enable) {
    environment.systemPackages = [ pkgs.kubernetes-helm ];
  };
}
