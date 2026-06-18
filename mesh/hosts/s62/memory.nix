# 4GB VPS 内存优化（DediOne LA，网卡 eth0）
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
  networking.useDHCP = lib.mkDefault true;
  systemd.network.networks."50-eth0" = {
    matchConfig.Name = "eth0";
    networkConfig.DHCP = "yes";
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
