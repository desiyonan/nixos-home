{ config, lib, ... }:

let
  cfg = config.modules.devops;
in
{
  config = lib.mkIf (cfg.enable && cfg.waydroid.enable) {
    virtualisation.waydroid.enable = true;
    virtualisation.lxd.enable = true;
  };
}
