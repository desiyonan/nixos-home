{ lib, pkgs, ... }:

let
  stateDir = "/var/lib/nixos-router-managed";
  bootstrapFile = "/var/lib/s01-router-bootstrap/config.json";
  bootstrapTemplate = pkgs.writeText "s01-router-bootstrap-template.json" (builtins.toJSON {
    system = { hostname = "srimsiuh-01"; timezone = "Asia/Shanghai"; };
    wan = { interface = "enp3s0"; mode = "dhcp"; };
    lan = {
      bridgeName = "br0";
      ipv4Cidr = "192.168.124.1/24";
      ports = [ "enp4s0" "enp5s0" "enp6s0" ];
      dhcp = {
        enable = true;
        rangeStart = "192.168.124.100";
        rangeEnd = "192.168.124.254";
        leaseMins = 67;
      };
    };
    dns = {
      enableDnsmasq = true;
      upstreams = [ "223.5.5.5" "223.6.6.6" ];
      domain = "nodes.dnfn.tech";
    };
    wifi = {
      enable = true;
      bridgeToLan = false;
      network = {
        ipv4Cidr = "192.168.125.1/24";
        allowManagement = true;
        allowWiredAccess = true;
        dhcp = {
          enable = true;
          rangeStart = "192.168.125.100";
          rangeEnd = "192.168.125.254";
          leaseMins = 67;
        };
      };
      aps = [{
        enable = true;
        ssid = "DnFn-GW-5G";
        standard = "wifi7";
        band = "5g";
        channel = 149;
        channelWidthMHz = 80;
        security = "wpa3-sae";
        psk = "";
      }];
    };
    firewall = { enable = true; natEnabled = true; };
    ipv6 = {
      enable = true;
      wanMode = "dhcpv6";
      lanPrefixDelegation = false;
      lanRouterAdvertisement = false;
    };
  });
in
{
  # WAN、LAN、AP 的地址、租约、NAT 和防火墙由执行器独占。
  networking = {
    useDHCP = false;
    dhcpcd.enable = false;
    firewall.enable = false;
    nat.enable = false;
    nftables.enable = false;
    domain = "nodes.dnfn.tech";
    nameservers = [ "223.5.5.5" "223.6.6.6" ];
  };
  services.kea.dhcp4.enable = false;
  services.kea.dhcp6.enable = false;
  services.hostapd.enable = false;

  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom=CN
  '';
  # 旧 dhcpcd 会留下 addr_gen_mode=none；WAN6 仍需内核生成链路本地地址。
  boot.kernel.sysctl."net.ipv6.conf.enp3s0.addr_gen_mode" = 0;

  # 执行器独占桥接创建；在 br0 出现后启用 STP，重建时自动重新应用。
  # 不在执行器之前等待 br0，否则首次启动会产生依赖死锁。
  systemd.services.s01-br0-stp = {
    description = "Enable spanning tree on the managed LAN bridge";
    wantedBy = [ "multi-user.target" "sys-subsystem-net-devices-br0.device" ];
    bindsTo = [ "sys-subsystem-net-devices-br0.device" ];
    after = [ "sys-subsystem-net-devices-br0.device" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iproute2}/bin/ip link set dev br0 type bridge stp_state 1";
    };
  };

  services.nixos-router.backend = {
    inherit stateDir;
    managed = {
      enable = true;
      interfaces = [ "enp3s0" "enp4s0" "enp5s0" "enp6s0" ];
      wifiInterface = "wlp1s0";
      countryCode = "CN";
      bootstrapConfigFile = bootstrapFile;
      apiStateDir = "/var/lib/nixos-router-api";
      # 仅授权当前管理主机；ZeroTier 传输与隧道内管理权限分别配置。
      managementAccess = [{
        interface = "zthnhcccz5";
        sources = [ "10.241.3.1/32" ];
      }];
      wanUDPPorts = [ 9993 ];
      confirmationTimeoutSeconds = 180;
    };
  };

  # 密码仅通过运行时凭据读取，不进入 Nix store。旧数据库保留供回退。
  systemd.services.s01-router-bootstrap = {
    description = "Prepare gateway bootstrap and preserve router accounts";
    requiredBy = [ "nixos-router-state-init.service" "nixos-router-executor.service" ];
    before = [ "nixos-router-state-init.service" "nixos-router-executor.service" ];
    after = [ "local-fs.target" ];
    path = [ pkgs.coreutils pkgs.jq pkgs.sqlite ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      UMask = "0077";
      StateDirectory = "s01-router-bootstrap";
      StateDirectoryMode = "0700";
      LoadCredential = [ "wifi-psk:/var/lib/hostapd/lan-wifi.passphrase" ];
    };
    script = ''
      set -euo pipefail
      bootstrap_tmp=$(mktemp /var/lib/s01-router-bootstrap/config.XXXXXX)
      trap 'rm -f "$bootstrap_tmp"' EXIT
      jq --rawfile psk "$CREDENTIALS_DIRECTORY/wifi-psk" \
        '.wifi.aps[0].psk = ($psk | sub("[\\r\\n]+$"; ""))' \
        ${bootstrapTemplate} > "$bootstrap_tmp"
      chmod 0600 "$bootstrap_tmp"
      mv -f "$bootstrap_tmp" ${bootstrapFile}
      install -d -m 0700 ${stateDir}
      if test ! -e ${stateDir}/state.db && test -f /var/lib/nixos-router/state.db; then
        # SQLite backup API includes WAL contents without copying a live DB file.
        sqlite3 /var/lib/nixos-router/state.db ".backup '${stateDir}/state.db'"
        chmod 0600 ${stateDir}/state.db
      fi
    '';
  };
}
