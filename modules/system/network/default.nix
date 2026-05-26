{ config, lib, pkgs, ... }:

let
  cfg = config.modules.network;
  proxyCfg = cfg.proxy;
in
{
  imports = [
    ./mihomo-service.nix
  ];

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
          System-wide HTTP(S) proxy and `services.mihomo` (default http://localhost:7890).

          Config: `modules.secrets` + secret-hub → `/run/secrets/programs/mihomo/config.yaml`.
          Web UI: http://127.0.0.1:9090/ui/ (metacubexd, when mihomo.webui.enable).
        '';
      };

      url = lib.mkOption {
        type = lib.types.str;
        default = "http://localhost:7890";
        description = "Proxy URL for allProxy, httpProxy, and httpsProxy.";
      };

      mihomo = {
        configFile = lib.mkOption {
          type = lib.types.path;
          default = "/run/secrets/programs/mihomo/config.yaml";
          description = "Mihomo config (SOPS decrypted at boot).";
        };

        webui = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Serve metacubexd at http://127.0.0.1:9090/ui/ (-ext-ui).";
          };
        };

        tunMode = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "CAP_NET_ADMIN for mihomo when TUN is enabled in config.yaml.";
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

      systemd.services.nix-daemon.environment = {
        HTTP_PROXY = proxyCfg.url;
        HTTPS_PROXY = proxyCfg.url;
        http_proxy = proxyCfg.url;
        https_proxy = proxyCfg.url;
        ALL_PROXY = proxyCfg.url;
        NO_PROXY = config.networking.proxy.noProxy;
      };
    })
    (lib.mkIf cfg.resolved.enable {
      services.resolved = {
        enable = true;
        settings.Resolve = {
          DNSSEC = cfg.resolved.dnssec;
          Domains = cfg.resolved.domains;
          FallbackDNS = cfg.resolved.fallbackDns;
        };
      };
    })
  ]);
}
