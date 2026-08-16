# 仅随图形桌面启用：蓝牙智能设备近距动态锁/解锁（Windows Dynamic Lock 同类）
{ config, lib, pkgs, ... }:

let
  graphical = config.modules.graphical;
  cfg = graphical.bluelock;
in
{
  options.modules.graphical.bluelock = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Bluetooth proximity lock/unlock for Plasma (phone / watch / earbuds).
        Walk away → lock; return → unlock. Ignored unless modules.graphical.enable.
      '';
    };

    proximity = lib.mkOption {
      type = lib.types.enum [ "ble-scan" "connection" ];
      default = "ble-scan";
      description = ''
        Default proximity mode (E). Switchable in BlueLock Preferences;
        a saved ~/.config/bluelock/config.toml value takes precedence.

        E (ble-scan): continuous BLE advertisement scan; presence from fresh RSSI.
        A (connection): presence from BlueZ Connected; disconnect + lock_duration
        locks, reconnect unlocks. Use A if the phone stops advertising while connected.
      '';
    };
  };

  config = lib.mkIf (graphical.enable && cfg.enable) {
    modules.bluetooth.enable = lib.mkDefault true;

    environment.systemPackages = [ pkgs.bluelock ];

    # 登录图形会话后托盘常驻；设备在 BlueLock 偏好设置里选择
    systemd.user.services.bluelock = {
      description = "Bluetooth proximity session lock (BlueLock)";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      environment.BLUELOCK_PROXIMITY_MODE = cfg.proximity;
      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.bluelock}";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
