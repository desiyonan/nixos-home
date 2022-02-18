{ config, pkgs, ... }:

{
  sound.enable = true;

  hardware = {
    bluetooth = {
      enable = true;
      settings.General.ControllerMode = "bredr";
    };

    pulseaudio.enable = true;
  };
}
