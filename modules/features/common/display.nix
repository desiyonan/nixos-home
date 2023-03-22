{ config, pkgs, ... }:

{
  programs.xwayland.enable = true;
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
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    vaapiIntel
    libvdpau-va-gl 
    vaapiVdpau 
    intel-ocl 
    mesa 
    glxinfo 
  ];

  environment.variables = {
    VDPAU_DRIVER = pkgs.lib.mkIf config.hardware.opengl.enable (pkgs.lib.mkDefault "va_gl");
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
