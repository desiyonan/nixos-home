{ config, pkgs, mpkgs, lib, ... }:
with lib;

let
  cfg = config.services.clash;
in {
  options.services.clash = {
    enable = mkOption {
      description = "Enable Clash daemon Systemd Service";
      type = types.bool;
      default = false;
    };

    configDir = mkOption {
      description = "clash configuration directory";
      type = types.str;
      # default = "~/.config/clash";
      default = "/etc/clash";
    };
  };

  config = mkIf(cfg.enable) {
    environment.systemPackages = with pkgs; [
      clash
    ];

    systemd.services.clash = {
      enable = true;
      description = "Clash daemon, A rule-based proxy in Go.";
      script = "${pkgs.clash}/bin/clash -d ${cfg.configDir}";
      serviceConfig = {
        Restart = "always";
        RestartSec = 5;
      };
      wants = [
        "multi-user.target"
        "network-online.target"
      ];
      after = [
        "network-online.target"
      ];
    };
  };
}