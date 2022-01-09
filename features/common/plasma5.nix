{ config, pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      desktopManager.gnome.enable = true;
      desktopManager.plasma5.enable = true;
      desktopManager.plasma5.runUsingSystemd = true;
    };
  };
}
