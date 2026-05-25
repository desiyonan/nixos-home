{ config, lib, pkgs, ... }:

let
  cfg = config.modules.network;
  proxyCfg = cfg.proxy;
  verge = pkgs.clash-verge-rev;
in
{
  options.modules.network = {
    enable = lib.mkEnableOption "System networking (proxy, systemd-resolved, NetworkManager)";

    enableIPv6 = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable IPv6.";
    };

    networkManager = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable NetworkManager.";
      };
    };

    proxy = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          System-wide HTTP(S) proxy and local Mihomo (Clash) daemon (default http://localhost:7890).

          Enables networking.proxy, environment variables, nix-daemon proxy, and
          systemd service `clash` (verge-mihomo). GUI: `clash-verge` → external :9090.
        '';
      };

      url = lib.mkOption {
        type = lib.types.str;
        default = "http://localhost:7890";
        description = "Proxy URL for allProxy, httpProxy, and httpsProxy.";
      };

      clash = {
        configDir = lib.mkOption {
          type = lib.types.str;
          default = "/etc/clash";
          description = "Mihomo configuration directory (config.yaml).";
        };
      };
    };

    resolved = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable systemd-resolved.";
      };
      dnssec = lib.mkOption {
        type = lib.types.str;
        default = "false";
        description = "DNSSEC mode for systemd-resolved.";
      };
      domains = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "nodes.dnfn.tech" ];
        description = "DNS search domains.";
      };
      fallbackDns = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "223.5.5.5"
          "223.6.6.6"
          "8.8.8.8"
          "1.1.1.1"
        ];
        description = "Fallback DNS servers.";
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      networking.enableIPv6 = cfg.enableIPv6;
      networking.networkmanager.enable = cfg.networkManager.enable;

      environment.systemPackages = [ pkgs.iw ];
    }
    (lib.mkIf proxyCfg.enable {
      networking.proxy = {
        allProxy = proxyCfg.url;
        httpProxy = proxyCfg.url;
        httpsProxy = proxyCfg.url;
        noProxy = "127.0.0.1,localhost";
      };

      environment.variables = config.networking.proxy.envVars // {
        HTTP_PROXY = proxyCfg.url;
        HTTPS_PROXY = proxyCfg.url;
        ALL_PROXY = proxyCfg.url;
        NO_PROXY = config.networking.proxy.noProxy;
      };

      # Nix 2.24+ 不再接受 nix.conf 的 http-proxy/https-proxy，改由 daemon 环境变量
      systemd.services.nix-daemon.environment = {
        HTTP_PROXY = proxyCfg.url;
        HTTPS_PROXY = proxyCfg.url;
        http_proxy = proxyCfg.url;
        https_proxy = proxyCfg.url;
        ALL_PROXY = proxyCfg.url;
        NO_PROXY = config.networking.proxy.noProxy;
      };

      environment.systemPackages = [ verge ];

      systemd.services.clash = {
        enable = true;
        description = "Mihomo proxy (Clash Verge Rev kernel)";
        script = "${verge}/bin/verge-mihomo -d ${proxyCfg.clash.configDir}";
        serviceConfig = {
          Restart = "always";
          RestartSec = 5;
        };
        wants = [ "multi-user.target" "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
      };
    })
    (lib.mkIf cfg.resolved.enable {
      services.resolved = {
        enable = true;
        dnssec = cfg.resolved.dnssec;
        domains = cfg.resolved.domains;
        fallbackDns = cfg.resolved.fallbackDns;
      };
    })
  ]);
}
