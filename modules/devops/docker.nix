{ config, lib, pkgs, ... }:

let
  cfg = config.modules.devops;

  hasNetworkProxy =
    config.modules.network.enable && config.modules.network.proxy.enable;
  hasSystemProxy = hasNetworkProxy;

  proxyUrlDefault =
    if hasNetworkProxy then
      config.modules.network.proxy.url
    else
      "http://127.0.0.1:7890";

  dockerCfg = let
    d = cfg.docker;
  in {
    enable = d.enable;
    daemon = {
      enable = d.daemon.enable;
      proxy = {
        enable = d.daemon.proxy.enable;
        url = d.daemon.proxy.url;
      };
    };
    active = cfg.enable && d.enable;
    daemonActive = cfg.enable && d.enable && d.daemon.enable;
    proxyActive = cfg.enable && d.enable && d.daemon.enable && d.daemon.proxy.enable;
  };
in
{
  options.modules.devops.docker = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Docker CLI (docker, docker-client)";
    };
    daemon = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Run Docker background daemon (virtualisation.docker).";
      };
      proxy = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            HTTP(S) proxy on docker.service. Defaults to on when
            modules.network.proxy is enabled.
          '';
        };
        url = lib.mkOption {
          type = lib.types.str;
          default = "http://127.0.0.1:7890";
          description = "Proxy URL for docker.service.";
        };
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      modules.devops.docker.daemon.proxy.enable = lib.mkDefault hasSystemProxy;
      modules.devops.docker.daemon.proxy.url = lib.mkDefault proxyUrlDefault;
    })
    (lib.mkIf dockerCfg.active (
      lib.mkMerge [
        {
          environment.systemPackages = with pkgs; [
            docker
            docker-client
          ];
        }
        (lib.mkIf dockerCfg.daemonActive {
          virtualisation.docker.enable = true;
        })
        (lib.mkIf dockerCfg.proxyActive {
          systemd.services.docker.environment = {
            ALL_PROXY = dockerCfg.daemon.proxy.url;
            HTTP_PROXY = dockerCfg.daemon.proxy.url;
            HTTPS_PROXY = dockerCfg.daemon.proxy.url;
          };
        })
      ]
    ))
  ];
}
