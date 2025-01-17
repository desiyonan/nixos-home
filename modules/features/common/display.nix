{ config, pkgs, ... }:

{
  programs.xwayland.enable = true;
  # programs.xwayland.enable = false;
#   programs.qt5ct.enable = true;
  services = {
    desktopManager={
      plasma6={
        enable = true;
      };
    };
    displayManager= {
      sddm={
        enable=true;
        wayland.enable=true;
      };
      defaultSession = "plasma";
    };
    xserver = {
      enable = true;
      desktopManager = {
        # plasma5.enable = true;
        # plasma5.runUsingSystemd = true;
        # gnome.enable = true;
      };
      # displayManager = {
      #   gdm.enable = true;
      #   gdm.wayland = true;
      #   # defaultSession = "plasmawayland";
      #   defaultSession = "plasma";
      # };
    };
  };

  # environment = {
  #   systemPackages = with pkgs; [
  #     qt5ct
  #     # qt5.full
  #     qt6.full
  #   ];
  #   variables = {
  #     MOZ_ENABLE_WAYLAND="1";
  #   };
  #   sessionVariables = {
  #     MOZ_ENABLE_WAYLAND="1";
  #   };
  # };

}
