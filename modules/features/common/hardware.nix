{ config, pkgs, ... }:

{

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.ControllerMode = "dual";
    };
  };

  hardware.enableAllFirmware = true;
  hardware.firmware = [
    # pkgs.firmwareLinuxNonfree
  ];

}
