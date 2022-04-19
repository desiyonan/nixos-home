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

  environment = {
    systemPackages = with pkgs; [
      mesa
      weston
      libdrm
      libinput
      xwayland
      egl-wayland
      wayland-protocols
      libsForQt5.plasma-wayland-protocols
      libsForQt5.qt5.qtwayland
    ];
    variables = {
      MOZ_ENABLE_WAYLAND="1";
    };
    sessionVariables = {
      MOZ_ENABLE_WAYLAND="1";
    };
  };
}
