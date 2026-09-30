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

          Config: secret-hub → `/run/secrets/programs/mihomo/config.yaml`.
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

      # Docker / VPN / 虚拟网卡不交 NM 管，减轻托盘枚举与 D-Bus 负担
      networking.networkmanager.unmanaged = [
        "interface-name:docker0"
        "interface-name:br-*"
        "interface-name:veth*"
        "interface-name:tailscale0"
        "interface-name:tun*"
        "interface-name:zt*"
      ];

      environment.systemPackages = [ pkgs.iw ];
    }
    (lib.mkIf (!cfg.enableIPv6) {
      # 仅作用于「新建」连接；已有 Wi-Fi 等 profile 仍可能是 ipv6.method=auto
      networking.networkmanager.settings.connection."ipv6.method" = lib.mkDefault "disabled";

      # 启动后把全部已有 profile 改成 disabled，避免 NM 对已 disable 的内核接口反复配 fe80
      systemd.services.nm-disable-ipv6-profiles = {
        description = "Force NetworkManager profiles to ipv6.method=disabled";
        wantedBy = [ "multi-user.target" ];
        after = [ "NetworkManager.service" ];
        wants = [ "NetworkManager.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "nm-disable-ipv6-profiles" ''
            set -euo pipefail
            nmcli=${pkgs.networkmanager}/bin/nmcli
            "$nmcli" -t -f UUID connection show | while read -r uuid; do
              [[ -z "$uuid" ]] && continue
              cur=$("$nmcli" -g ipv6.method connection show uuid "$uuid" 2>/dev/null || true)
              if [[ "$cur" != "disabled" && "$cur" != "ignore" ]]; then
                "$nmcli" connection modify uuid "$uuid" ipv6.method disabled || true
              fi
            done
            # 已连接设备立刻按新 profile 重应用，停掉 IPv6LL 重试循环
            "$nmcli" -t -f DEVICE,STATE device status | while IFS=: read -r dev state _; do
              [[ "$state" == connected* && -n "$dev" && "$dev" != lo ]] || continue
              "$nmcli" device reapply "$dev" 2>/dev/null || true
            done
          '';
        };
      };

      environment.etc."NetworkManager/dispatcher.d/99-disable-ipv6" = {
        source = pkgs.writeShellScript "99-disable-ipv6" ''
          # NetworkManager dispatcher: $1=iface $2=action
          if [[ "''${2:-}" == up && -n "''${1:-}" && "''${1}" != lo ]]; then
            ${pkgs.procps}/sbin/sysctl -w "net.ipv6.conf.''${1}.disable_ipv6=1" >/dev/null 2>&1 || true
            # 活动连接若仍是 auto，改掉并 reapply，避免日志刷屏
            con=$(${pkgs.networkmanager}/bin/nmcli -g GENERAL.CONNECTION device show "$1" 2>/dev/null || true)
            if [[ -n "$con" && "$con" != "--" ]]; then
              cur=$(${pkgs.networkmanager}/bin/nmcli -g ipv6.method connection show "$con" 2>/dev/null || true)
              if [[ "$cur" != "disabled" && "$cur" != "ignore" ]]; then
                ${pkgs.networkmanager}/bin/nmcli connection modify "$con" ipv6.method disabled 2>/dev/null || true
                ${pkgs.networkmanager}/bin/nmcli device reapply "$1" 2>/dev/null || true
              fi
            fi
          fi
        '';
        mode = "0755";
      };

      # glibc 解析：优先 IPv4，减少 Happy Eyeballs 先连 v6 再超时
      environment.etc."gai.conf".text = ''
        precedence ::ffff:0:0/96  100
      '';
    })
    (lib.mkIf proxyCfg.enable (
      let
        # 始终用 loopback，不绑会变的局域网 IP；sandbox 内 127.0.0.1 ≠ 宿主机，
        # 故同时关掉 sandbox，让 fetchurl builder 能打到本机 mihomo。
        proxyUrl = proxyCfg.url;
        noProxy = "127.0.0.1,localhost";
        proxyEnv = {
          HTTP_PROXY = proxyUrl;
          HTTPS_PROXY = proxyUrl;
          ALL_PROXY = proxyUrl;
          http_proxy = proxyUrl;
          https_proxy = proxyUrl;
          all_proxy = proxyUrl;
          NO_PROXY = noProxy;
          no_proxy = noProxy;
        };
      in
      {
        networking.proxy = {
          allProxy = proxyUrl;
          httpProxy = proxyUrl;
          httpsProxy = proxyUrl;
          noProxy = "127.0.0.1,localhost";
        };

        environment.variables = config.networking.proxy.envVars // proxyEnv;

        # daemon 拉 substituter 用
        systemd.services.nix-daemon.environment = proxyEnv;

        nix.settings = {
          # 不依赖客户端 shell 是否 export 了代理
          experimental-features = [ "configurable-impure-env" ];
          impure-env = lib.mapAttrsToList (n: v: "${n}=${v}") proxyEnv;
          sandbox = false;
        };
      }
    ))
    (lib.mkIf cfg.resolved.enable {
      services.resolved = {
        enable = true;
        settings.Resolve = lib.mkMerge [
          {
            DNSSEC = cfg.resolved.dnssec;
            Domains = cfg.resolved.domains;
            FallbackDNS = cfg.resolved.fallbackDns;
          }
          (lib.optionalAttrs (!cfg.enableIPv6) {
            # 仍返回 AAAA 时，应用会先试 IPv6 再回落，国内常见长时间卡顿
            RefuseRecordTypes = "AAAA";
            LLMNR = "no";
            MulticastDNS = "no";
          })
        ];
      };
    })
  ]);
}
