{ config, pkgs, ... }:

{
  programs.xwayland.enable = true;
  # programs.sway.enable = true;
  services.xserver.displayManager.defaultSession = "plasmawayland";
  # services.xserver.displayManager.gdm.nvidiaWayland = true;
}
