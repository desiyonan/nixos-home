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
    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = ["nvidia"];

    hardware.graphics = {
      enable = true;
      # driSupport = true;
      enable32Bit = true;
    };

    hardware.nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
      # of just the bare essentials.
      powerManagement.enable = true;
      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;
      prime = {
        sync.enable = true;
        # offload.enable = true;
        # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
        intelBusId = cfg.intelBusId;
        # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
        nvidiaBusId = cfg.nvidiaBusId;
      };
      #package = config.boot.kernelPackages.nvidiaPackages.stable;
      # package = config.boot.kernelPackages.nvidiaPackages.production;
    };
  };
}
