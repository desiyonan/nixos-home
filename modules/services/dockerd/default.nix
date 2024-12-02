{ config, pkgs,  lib, ... }:
with lib;

let
  cfg = config.services.dockerd;
in {
  options.services.dockerd = {
    enable = mkOption {
      description = "Enable Docker daemon Systemd Service";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf(cfg.enable) {
    environment.systemPackages = with pkgs; [
      docker
    ];

    systemd.services.dockerd = {
      enable = true;
      description = "Docker daemon.";
      unitConfig = {
        StartLimitBurst=3;
        StartLimitInterval="60s";
      };
      serviceConfig = {
        Type="notify";
        Restart = "on-failure";
        ExecStart = "${pkgs.docker}/bin/dockerd";
        ExecReload="/bin/kill -s HUP $MAINPID";
        Delegate="yes";
        RestartSec = 5;
        KillMode="process";
      };
      wants = [
        "network-online.target"
      ];
      after = [
        "network-online.target"
        "firewall.service"
      ];
      wantedBy = [
        "multi-user.target"
      ];
      environment = {
        ALL_PROXY = "http://127.0.0.1:7890";
        HTTP_PROXY = "http://127.0.0.1:7890";
        HTTPS_PROXY = "http://127.0.0.1:7890";
      };
    };
  };
}
