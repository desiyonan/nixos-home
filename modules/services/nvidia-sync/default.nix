{ config, pkgs,  lib, ... }:
with lib;

let
  cfg = config.services.nvidia-sync;
in {
  options.services.nvidia-sync = {
    enable = mkOption {
      description = "Enable nvidia-sync";
      type = types.bool;
      default = false;
    };
    nvidiaBusId = mkOption {
      description = "Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA";
      type = types.str;
      default = "PCI:1:0:0";
    };
    intelBusId = mkOption {
      description = "Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA";
      type = types.str;
      default =  "PCI:0:2:0";
    };
  };

  config = mkIf(cfg.enable) {
    hardware.nvidia = {
      modesetting.enable = true;
      # open = true;
      nvidiaSettings = true;
      powerManagement.finegrained = false;
      prime = {
        sync.enable = true;
        # offload.enable = true;
        # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
        intelBusId = cfg.intelBusId;
        # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
        nvidiaBusId = cfg.nvidiaBusId;
      };
      # package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    services.xserver.videoDrivers = [ "nvidia" ];
  };
}
