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

  networking.hostName = "gw";

  hardware.enableAllFirmware = true;

  environment.systemPackages = with pkgs; [
    conntrack-tools
    dnsmasq
    ethtool
    tcpdump
  ];

  system.stateVersion = "26.05";
}
