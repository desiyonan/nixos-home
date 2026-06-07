{ config, lib, ... }:

let
  cfg = config.modules.bluetooth;
in
{
  options.modules.bluetooth = {
    enable = lib.mkEnableOption "Bluetooth (BlueZ)";
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General = {
        Experimental = true;
        Enable = "Source,Sink,Media,Socket";
        ControllerMode = "dual";
      };
    };
  };
}
