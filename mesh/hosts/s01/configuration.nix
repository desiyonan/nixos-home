{ lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "srimsiuh-01";

  # I226-V 在回接 PPPoE 转发中出现 Tx Unit Hang（enp4s0、enp5s0）。
  # 四个同型号有线口统一使用软件 TCP 分段，保留 GRO、链路速率及双向转发。
  systemd.services = lib.listToAttrs (map (interface: {
    name = "s01-${interface}-tso";
    value = {
      description = "Disable TCP segmentation offload on ${interface}";
      wantedBy = [ "multi-user.target" "sys-subsystem-net-devices-${interface}.device" ];
      bindsTo = [ "sys-subsystem-net-devices-${interface}.device" ];
      after = [ "sys-subsystem-net-devices-${interface}.device" ];
      before = [ "nixos-router-executor.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.ethtool}/bin/ethtool -K ${interface} tso off";
      };
    };
  }) [ "enp3s0" "enp4s0" "enp5s0" "enp6s0" ]);

  # 网关使用固定时区，避免依赖桌面定位服务。
  services.automatic-timezoned.enable = lib.mkForce false;
  time.timeZone = "Asia/Shanghai";

  hardware.enableAllFirmware = true;

  hardware.mediatek-mt7927 = {
    enable = true;
    enableWifi = true;
    enableBluetooth = false;
    disableAspm = true;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    conntrack-tools
    ethtool
    hostapd
    iw
    tcpdump
    wpa_supplicant
  ];

  system.stateVersion = "26.05";
}
