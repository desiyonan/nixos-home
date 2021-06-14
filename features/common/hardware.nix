{ config, pkgs, ... }:

{
  sound.enable = true;

  hardware = {
    bluetooth = {
      enable = true;
      config.General.ControllerMode = "bredr";
    };

    pulseaudio.enable = true;
  };
}
