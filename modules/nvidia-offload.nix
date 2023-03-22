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
    hardware.opengl.enable = true;
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
    hardware.nvidia.forceFullCompositionPipeline = true;

    environment.systemPackages = with mpkgs; [
      # nvidia-offload
      (
        pkgs.writeShellScriptBin "nvidia-offload" 
        ''
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export __VK_LAYER_NV_optimus=NVIDIA_only
        exec "$@"
        ''
      )
    ];

    services.xserver.videoDrivers = [ 
      "nvidia" 
      "amdgpu"
      "radeon"
      "nouveau"
      "modesetting"
      "fbdev"
      # "amdgpu-pro"
    ];
  };
}
