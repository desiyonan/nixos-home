{ config, pkgs, ... }:

{
  sound.enable = false;

  hardware = {
    bluetooth = {
      enable = true;
      settings.General.ControllerMode = "dual";
    };

    pulseaudio.enable = false;
  };
}
