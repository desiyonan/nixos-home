# 1GB VPS 内存优化
{ lib, ... }:

{
  # journald：限制磁盘与运行时内存占用
  services.journald.extraConfig = ''
    SystemMaxUse=50M
    RuntimeMaxUse=30M
    MaxRetentionSec=7day
  '';

  # KVM 有线 VPS：不需要 Wi-Fi / 移动网络 / polkit（NM 专用）
  networking.wireless.enable = lib.mkForce false;
  networking.modemmanager.enable = false;
  security.polkit.enable = false;

  # systemd-networkd 替代 NetworkManager（省 ~16MiB + dbus 依赖链）
  networking.networkmanager.enable = lib.mkForce false;
  networking.useNetworkd = true;
  networking.useDHCP = lib.mkDefault true;
  systemd.network.networks."50-ens3" = {
    matchConfig.Name = "ens3";
    networkConfig.DHCP = "yes";
  };

  # 纯服务端：不需要 home-manager（dnf 仅 SSH 登录）
  home-manager.users = lib.mkForce { };

  users.users.dnf.extraGroups = lib.mkForce [
    "users"
    "wheel"
  ];

  # nix-daemon 已由 socket 激活；启动后释放常驻进程，deploy 时自动拉起
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
