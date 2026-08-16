{ config, lib, pkgs, ... }:

let
  cfg = config.modules.devops;
in
{
  config = lib.mkIf (cfg.enable && cfg.waydroid.enable) {
    virtualisation.waydroid.enable = true;
    # 默认 waydroid 包走 iptables-legacy；本机内核无 nf_tables、无 ip_tables 模块，
    # session 会在 waydroid-net.sh 失败（Module ip_tables not found）。
    virtualisation.waydroid.package = pkgs.waydroid-nftables;

    # waydroid-helper：配置 Waydroid、安装 Magisk / ARM 翻译等扩展的 GUI
    environment.systemPackages = [ pkgs.waydroid-helper ];

    # 安装 helper 自带的 system/user unit（挂载共享目录、会话监视）
    systemd.packages = [ pkgs.waydroid-helper ];
    services.dbus.packages = [ pkgs.waydroid-helper ];

    systemd.services.waydroid-mount.wantedBy = [ "multi-user.target" ];
    systemd.user.services.waydroid-monitor.wantedBy = [ "default.target" ];
  };
}
