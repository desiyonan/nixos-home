{ lib, pkgs, ... }:

let
  wanInterface = "enp3s0";
  lanBridge = "br0";
  lanInterfaces = [
    "enp4s0"
    "enp5s0"
    "enp6s0"
  ];
  wifiInterface = "wlp1s0";
  lanAddress = "192.168.124.1";
  wifiAddress = "192.168.125.1";
  lanPrefixLength = 24;
  wifiPassphraseFile = "/var/lib/hostapd/lan-wifi.passphrase";

  wifiRegCountry = "CN";
  wifi5gChannel = 149;
  wifi5gCenterSegIdx = 155; # ch149 @ 80 MHz → 5735 MHz
in
{
  networking = {
    useDHCP = false;
    domain = "nodes.dnfn.tech";
    nameservers = [
      "223.5.5.5"
      "223.6.6.6"
    ];

    interfaces.${wanInterface}.useDHCP = true;

    interfaces.${lanBridge} = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = lanAddress;
          prefixLength = lanPrefixLength;
        }
      ];
    };

    interfaces.${wifiInterface} = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = wifiAddress;
          prefixLength = lanPrefixLength;
        }
      ];
    };

    bridges.${lanBridge} = {
      rstp = true;
      interfaces = lanInterfaces;
    };

    nat = {
      enable = true;
      enableIPv6 = true;
      externalInterface = wanInterface;
      internalInterfaces = [
        lanBridge
        wifiInterface
      ];
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;

    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.all.autoconf" = 0;
    "net.ipv6.conf.all.use_tempaddr" = 0;

    "net.ipv6.conf.${wanInterface}.accept_ra" = 2;
    "net.ipv6.conf.${wanInterface}.autoconf" = 1;
  };

  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config.interfaces = [
        lanBridge
        wifiInterface
      ];
      lease-database = {
        name = "/var/lib/kea/dhcp4.leases";
        persist = true;
        type = "memfile";
      };
      rebind-timer = 2000;
      renew-timer = 1000;
      valid-lifetime = 4000;
      option-data = [
        {
          name = "domain-name-servers";
          data = "223.5.5.5";
          always-send = true;
        }
        {
          name = "domain-name";
          data = "nodes.dnfn.tech";
        }
      ];
      subnet4 = [
        {
          id = 1;
          subnet = "192.168.124.0/24";
          interface = lanBridge;
          option-data = [
            {
              name = "routers";
              data = lanAddress;
            }
          ];
          pools = [
            {
              pool = "192.168.124.100 - 192.168.124.254";
            }
          ];
        }
        {
          id = 2;
          subnet = "192.168.125.0/24";
          interface = wifiInterface;
          option-data = [
            {
              name = "routers";
              data = wifiAddress;
            }
          ];
          pools = [
            {
              pool = "192.168.125.100 - 192.168.125.254";
            }
          ];
        }
      ];
    };
  };

  # 监管域必须在 hostapd 选信道前生效；否则 country 00 下 ch149 为 NO-IR，AP 起不来并疯狂重启。
  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom=${wifiRegCountry}
  '';

  # 启动前：清理 DBDC 残留接口，并强制 iw reg set CN
  systemd.services.hostapd-prep = {
    description = "Prepare WiFi interface and regulatory domain before hostapd";
    after = [ "sys-subsystem-net-devices-${wifiInterface}.device" ];
    before = [ "hostapd.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.iw
      pkgs.iproute2
      pkgs.coreutils
      pkgs.gnugrep
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -euo pipefail
      for iface in wlp1s0-6g wlp1s0-1 wlp1s0-2; do
        if ip link show "$iface" &>/dev/null; then
          ip link set "$iface" down || true
          iw dev "$iface" del || true
        fi
      done

      iw reg set ${wifiRegCountry}
      for _ in $(seq 1 20); do
        if iw reg get | grep -q "country ${wifiRegCountry}:"; then
          break
        fi
        sleep 0.25
        iw reg set ${wifiRegCountry} || true
      done
      if ! iw reg get | grep -q "country ${wifiRegCountry}:"; then
        echo "ERROR: failed to set regulatory domain to ${wifiRegCountry}" >&2
        iw reg get >&2 || true
        exit 1
      fi
    '';
  };

  services.hostapd = {
    enable = true;
    radios.${wifiInterface} = {
      countryCode = wifiRegCountry;
      band = "5g";
      channel = wifi5gChannel;
      wifi4 = {
        capabilities = [
          "LDPC"
          "HT40+"
          "SHORT-GI-20"
          "SHORT-GI-40"
          "TX-STBC"
          "RX-STBC1"
          "MAX-AMSDU-7935"
        ];
      };
      wifi5 = {
        operatingChannelWidth = "80";
        capabilities = [
          "VHT160"
          "RXLDPC"
          "SHORT-GI-80"
          "SHORT-GI-160"
          "TX-STBC-2BY1"
          "RX-STBC-1"
          "SU-BEAMFORMEE"
          "MU-BEAMFORMEE"
        ];
      };
      wifi6 = {
        enable = true;
        operatingChannelWidth = "80";
      };
      wifi7 = {
        enable = true;
        operatingChannelWidth = "80";
      };
      settings = {
        vht_oper_centr_freq_seg0_idx = wifi5gCenterSegIdx;
        he_oper_centr_freq_seg0_idx = wifi5gCenterSegIdx;
        eht_oper_centr_freq_seg0_idx = wifi5gCenterSegIdx;
        he_bss_color = 1;
        he_default_pe_duration = 4;
        he_rts_threshold = 1023;
      };
      networks.${wifiInterface} = {
        ssid = "DnFn-GW-5G";
        utf8Ssid = true;
        authentication = {
          mode = "wpa3-sae";
          saePasswordsFile = wifiPassphraseFile;
        };
      };
    };
  };

  systemd.services.kea-dhcp4-server = {
    after = [ "hostapd.service" ];
    wants = [ "hostapd.service" ];
  };

  systemd.services.hostapd = {
    after = [
      "network-addresses-${wifiInterface}.service"
      "hostapd-prep.service"
    ];
    wants = [
      "network-addresses-${wifiInterface}.service"
      "hostapd-prep.service"
    ];
    requires = [ "hostapd-prep.service" ];
    serviceConfig = {
      # 失败时避免秒级重启打满日志（曾出现 30 万+ 次重启）
      RestartSec = "5s";
      StartLimitIntervalSec = 120;
      StartLimitBurst = 10;
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/hostapd 0755 root root -"
  ];
}
