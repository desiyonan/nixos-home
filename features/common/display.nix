{ config, pkgs, ... }:

{
  programs.xwayland.enable = true;
  programs.qt5ct.enable = true;
  services = {
    xserver = {
      enable = true;
      desktopManager = {
        plasma5.enable = true;
        plasma5.runUsingSystemd = true;
      };
      displayManager = {
        sddm.enable = true;
        defaultSession = "plasmawayland";
      };
    };
  };
}
