{ config, lib, pkgs, ... }:

let
  cfg = config.modules.devops;
in
{
  options.modules.devops.virtualbox.members = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ "dnf" ];
    description = "Users in the vboxusers group";
  };

  config = lib.mkIf (cfg.enable && cfg.virtualbox.enable) {
    virtualisation.virtualbox.host.enable = true;
    users.extraGroups.vboxusers.members = cfg.virtualbox.members;
  };
}
