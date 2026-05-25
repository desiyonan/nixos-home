{ config, pkgs, ... }:

{

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General = {
		    Experimental = true;
        Enable = "Source,Sink,Media,Socket";
        ControllerMode = "dual";
      };
    };
  };

  hardware.enableAllFirmware = true;
  hardware.firmware = [
    # pkgs.firmwareLinuxNonfree
  ];

}
