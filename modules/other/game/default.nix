{ config, lib, ... }:
{
  options.modules.game = {
    enable = lib.mkEnableOption "Gaming-related modules";

    steam = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Steam when the game module is enabled.";
      };
      remotePlay.openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open firewall ports for Steam Remote Play.";
      };
      dedicatedServer.openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open firewall ports for Source Dedicated Server.";
      };
      localNetworkGameTransfers.openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open firewall ports for Steam local network game transfers.";
      };
    };
  };

  imports = [ ./steam.nix ];
}
