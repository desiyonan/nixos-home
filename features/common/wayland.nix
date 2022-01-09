{ config, pkgs, ... }:

{
  programs.xwayland.enable = true;
  services.xserver.displayManager.defaultSession = "plasmawayland";
}
