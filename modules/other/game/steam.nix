{ config, lib, ... }:

let
  cfg = config.modules.game;
  steam = cfg.steam;
in
{
  config = lib.mkIf (cfg.enable && steam.enable) {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = steam.remotePlay.openFirewall;
      dedicatedServer.openFirewall = steam.dedicatedServer.openFirewall;
      localNetworkGameTransfers.openFirewall = steam.localNetworkGameTransfers.openFirewall;
    };
  };
}
