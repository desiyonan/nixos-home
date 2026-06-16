{ config, lib, ... }:

let
  cfg = config.modules.headscale;
in
{
  options.modules.headscale = {
    enable = lib.mkEnableOption "Headscale control server with Headplane web UI";

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open firewall ports for Headscale API and Headplane web UI.";
    };

    headscalePort = lib.mkOption {
      type = lib.types.port;
      default = 26616;
      description = "Headscale HTTP API listening port.";
    };

    headplanePort = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Headplane web UI listening port.";
    };

    serverUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:26616";
      description = "Public URL advertised by Headscale (services.headscale.settings.server_url).";
    };

    headplaneUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:26616";
      description = "Headscale API URL used by Headplane.";
    };

    headplaneConfigPath = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/headplane/config.yaml";
      description = ''
        Host path to headplane config file. This file is expected to be
        provisioned by secret-hub and mounted into the container at
        /etc/headplane/config.yaml.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.headscalePort != cfg.headplanePort;
        message = "modules.headscale.headscalePort and headplanePort must be different.";
      }
    ];

    services.headscale = {
      enable = true;
      address = "0.0.0.0";
      port = cfg.headscalePort;
      settings = {
        server_url = cfg.serverUrl;
        dns = {
          magic_dns = false;
          override_local_dns = false;
        };
      };
    };

    virtualisation.podman.enable = true;
    virtualisation.oci-containers.backend = "podman";
    virtualisation.oci-containers.containers.headplane = {
      image = "ghcr.io/tale/headplane:latest";
      ports = [ "${toString cfg.headplanePort}:3000" ];
      volumes = [
        "${cfg.headplaneConfigPath}:/etc/headplane/config.yaml:ro"
        "/var/lib/headplane:/var/lib/headplane"
      ];
      extraOptions = [ "--pull=always" ];
    };

    systemd.services.podman-headplane = {
      after = [ "network-online.target" "sops-nix.service" ];
      requires = [ "sops-nix.service" ];
      wants = [ "network-online.target" ];
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/headplane 0750 root root -"
    ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      cfg.headscalePort
      cfg.headplanePort
    ];
  };
}
