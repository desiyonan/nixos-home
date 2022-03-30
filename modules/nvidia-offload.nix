{ config, pkgs, mpkgs, lib, ... }:
with lib;

let
  cfg = config.services.nvidia-offload;
in {
  options.services.nvidia-offload = {
    enable = mkOption {
      description = "Enable nvidia-offload";
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
    hardware.nvidia.modesetting.enable = true;
    hardware.nvidia.prime = {
      #sync.enable = true;
      offload.enable = true;
      # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
      intelBusId = cfg.intelBusId;
      # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
      nvidiaBusId = cfg.nvidiaBusId;
    };

    environment.systemPackages = with mpkgs; [
      nvidia-offload
    ];

    services.xserver.videoDrivers = [ "nvidia" ];
  };
}
