{ config, pkgs, ... }:

{
  sound.enable = true;

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.ControllerMode = "dual";
    };

    pulseaudio.enable = false;
  };

  hardware.enableAllFirmware = true;
  hardware.firmware = [
    pkgs.firmwareLinuxNonfree
  ];

}
