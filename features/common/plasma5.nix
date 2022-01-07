{ config, pkgs, ... }:

{
  # programs.xwayland.enable = true;
  services = {
    xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
      displayManager.defaultSession = "plasmawayland";
      windowManager.i3.enable = true;
    };
  };
}
