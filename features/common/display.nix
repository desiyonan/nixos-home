{ config, pkgs, ... }:

{
#   programs.xwayland.enable = true;
#   programs.qt5ct.enable = true;
  services = {
    xserver = {
      enable = true;
      desktopManager = {
        plasma5.enable = true;
        # plasma5.runUsingSystemd = true;
      };
      displayManager = {
        gdm.enable = true;
        gdm.wayland = true;
        defaultSession = "plasmawayland";
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      qt5ct
    ];
    variables = {
      MOZ_ENABLE_WAYLAND="1";
    };
    sessionVariables = {
      MOZ_ENABLE_WAYLAND="1";
    };
  };
}
