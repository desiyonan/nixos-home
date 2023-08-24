{ config, pkgs, ... }:

{
  sound.enable = true;

  hardware = {
    bluetooth = {
      enable = true;
      settings.General.ControllerMode = "dual";
    };

    pulseaudio.enable = true;
  };
}
