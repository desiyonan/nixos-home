{ config, lib, pkgs, ... }:

let
  cfg = config.modules.devops;
in
{
  config = lib.mkIf (cfg.enable && cfg.aliyun.enable) {
    environment.systemPackages = [ pkgs.aliyun-cli ];
  };
}
