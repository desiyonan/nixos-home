{ pkgs, ... }:

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

  networking.hostName = "gw";

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
