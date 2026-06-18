# 4GB VPS 内存优化（静态 IP，网卡 ens17）
{ lib, ... }:

{
  services.journald.extraConfig = ''
    SystemMaxUse=100M
    RuntimeMaxUse=50M
    MaxRetentionSec=7day
  '';

  networking.wireless.enable = lib.mkForce false;
  networking.modemmanager.enable = false;
  security.polkit.enable = false;

  networking.networkmanager.enable = lib.mkForce false;
  networking.useNetworkd = true;
  networking.useDHCP = lib.mkForce false;
  systemd.network.networks."50-ens17" = {
    matchConfig.Name = "ens17";
    networkConfig = {
      Address = [
        "45.144.136.16/24"
        "2001:df1:7880:100::871/64"
      ];
      DNS = [
        "172.16.36.100"
        "172.16.36.101"
      ];
    };
    routes = [
      {
        Destination = "0.0.0.0/0";
        Gateway = "45.144.136.254";
      }
      {
        Destination = "::/0";
        Gateway = "2001:df1:7880:100::1";
      }
    ];
  };

  home-manager.users = lib.mkForce { };

  users.users.dnf.extraGroups = lib.mkForce [
    "users"
    "wheel"
  ];

  systemd.services.nix-daemon-idle-stop = {
    description = "Stop idle nix-daemon after boot (socket stays for on-demand)";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      sleep 120
      if systemctl is-active --quiet nix-daemon.service; then
        systemctl stop nix-daemon.service
      fi
    '';
  };
}
