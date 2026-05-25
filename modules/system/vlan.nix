{ config, lib, pkgs, ... }:

let
  cfg = config.modules.vlan;
in
{
  options.modules.vlan = {
    enable = lib.mkEnableOption "Virtual LAN overlay (Tailscale and/or ZeroTier)";

    tailscale = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Tailscale when VLAN module is enabled.";
      };
      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open firewall for Tailscale.";
      };
    };

    zerotier = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable ZeroTier when VLAN module is enabled.";
      };
      joinNetworks = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "af78bf94369e9f0b" ];
        description = "ZeroTier network IDs to join on boot.";
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf cfg.tailscale.enable {
      services.tailscale = {
        enable = true;
        openFirewall = cfg.tailscale.openFirewall;
      };
      environment.systemPackages = [ pkgs.tailscale ];
    })
    (lib.mkIf cfg.zerotier.enable {
      services.zerotierone = {
        enable = true;
        joinNetworks = cfg.zerotier.joinNetworks;
      };
    })
  ]);
}
