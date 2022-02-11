{ config, pkgs, ... }:

{
  programs.xwayland.enable = true;
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
