{ config, lib, pkgs, ... }:

let
  cfg = config.modules.devops;
in
{
  config = lib.mkIf (cfg.enable && cfg.etcd.enable) {
    environment.systemPackages = [ pkgs.etcd ];
  };
}
