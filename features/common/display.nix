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
        # sddm.enable = true;
        defaultSession = "plasmawayland";
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      qt5ct
      # mesa
      # weston
      # libdrm
      # libinput
      # wayland
      # xwayland
      # egl-wayland
      # wayland-protocols
      # libsForQt5.plasma-wayland-protocols
      # libsForQt5.qt5.qtwayland
    ];
    variables = {
      MOZ_ENABLE_WAYLAND="1";
    };
    sessionVariables = {
      MOZ_ENABLE_WAYLAND="1";
    };
  };
}
