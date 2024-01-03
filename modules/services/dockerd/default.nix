{ config, pkgs, mpkgs, lib, ... }:
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
      script = "${pkgs.docker}/bin/dockerd";
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
      environment = {
        ALL_PROXY = "http://127.0.0.1:7890";
        HTTP_PROXY = "http://127.0.0.1:7890";
        HTTPS_PROXY = "http://127.0.0.1:7890";
      };
    };
  };
}
