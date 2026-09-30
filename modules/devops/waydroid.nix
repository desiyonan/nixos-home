{ config, lib, pkgs, ... }:

let
  cfg = config.modules.devops;
  waydroidPkg = pkgs.waydroid-nftables;

  # Appium Settings：向 Android 注入 mock location（NixOS Wiki / geobridge 同款）
  appiumSettingsApk = pkgs.fetchurl {
    url = "https://github.com/appium/io.appium.settings/releases/download/v5.12.14/settings_apk-debug.apk";
    hash = "sha256-Dk7ZvcBfcJKahvtHEYDrEZnQ6+VOpI130RyWMC8V9+I=";
  };

  waydroidGpsPriv = pkgs.writeShellApplication {
    name = "waydroid-gps-priv";
    runtimeInputs = [ waydroidPkg ];
    text = builtins.readFile ./waydroid-gps-priv.sh;
  };

  waydroidGps = pkgs.writeShellApplication {
    name = "waydroid-gps";
    runtimeInputs = [
      waydroidPkg
      pkgs.gnugrep
    ];
    text = ''
      export APPIUM_APK=${lib.escapeShellArg (toString appiumSettingsApk)}
      export HOST_LAT=${lib.escapeShellArg (toString config.location.latitude)}
      export HOST_LON=${lib.escapeShellArg (toString config.location.longitude)}
      export WAYDROID_GPS_PRIV=${lib.escapeShellArg (lib.getExe waydroidGpsPriv)}
      ${builtins.readFile ./waydroid-gps.sh}
    '';
  };
in
{
  config = lib.mkIf (cfg.enable && cfg.waydroid.enable) {
    virtualisation.waydroid.enable = true;
    # 默认 waydroid 包走 iptables-legacy；本机内核无 nf_tables、无 ip_tables 模块，
    # session 会在 waydroid-net.sh 失败（Module ip_tables not found）。
    virtualisation.waydroid.package = waydroidPkg;

    # systemd 258 已通过 uaccess 处理 adb 设备权限，不必再开 programs.adb / adbusers

    # waydroid shell 需要 root；仅放行本助手，避免每次模拟 GPS 都输密码
    security.sudo.extraRules = [
      {
        groups = [ "wheel" ];
        commands = [
          {
            command = lib.getExe waydroidGpsPriv;
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    # waydroid-helper：配置 Waydroid、安装 Magisk / ARM 翻译等扩展的 GUI
    environment.systemPackages = [
      pkgs.android-tools
      pkgs.waydroid-helper
      waydroidGps
    ];

    # 安装 helper 自带的 system/user unit（挂载共享目录、会话监视）
    systemd.packages = [ pkgs.waydroid-helper ];
    services.dbus.packages = [ pkgs.waydroid-helper ];

    systemd.services.waydroid-mount.wantedBy = [ "multi-user.target" ];
    systemd.user.services.waydroid-monitor.wantedBy = [ "default.target" ];
  };
}
