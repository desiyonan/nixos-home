{ config, pkgs,  lib, ... }:
with lib;

let
  cfg = config.services.nvidia-prime;
in {
  options.services.nvidia-prime = {
    enable = mkOption {
      description = "Enable nvidia-prime";
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
      open = false;
      modesetting.enable = true;
      nvidiaSettings = true;
      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
      # of just the bare essentials.
      # powerManagement.enable = true;
      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      # powerManagement.finegrained = false;
      prime = {
        sync.enable = true;
        offload = {
          enable = false;
          enableOffloadCmd = false;
        };
        # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
        intelBusId = cfg.intelBusId;
        # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
        nvidiaBusId = cfg.nvidiaBusId;
      };
      #package = config.boot.kernelPackages.nvidiaPackages.stable;
      # package = config.boot.kernelPackages.nvidiaPackages.mkDriver rec {
      #   version = "580.159.03";
      #   url = "https://download.nvidia.com/XFree86/Linux-x86_64/${version}/NVIDIA-Linux-x86_64-${version}.run";
      #   sha256_64bit = "sha256-MshdmbD2QMlQH2GzndrSCP0CiNAVxPvF/QQ1wHeD+nc=";
      #   openSha256 = "0cz31348jvrjqs08a21dqjwlpjg5fwx4ck8d4y56lp96yz4qjl8y";
      #   settingsSha256 = "sha256-kP3J87uUVPOOJHmTdRNm4+GdIyniZYrtgehrYSXcX9A=";
      #   persistencedSha256 = "127a9m3ldbq3999z1j7wx6x2m38y1va7vbpq58kylqcjhv7sl3vi";
      # };
      package = config.boot.kernelPackages.nvidiaPackages.mkDriver rec {
        version = "580.126.18";
        url = "https://download.nvidia.com/XFree86/Linux-x86_64/${version}/NVIDIA-Linux-x86_64-${version}.run";
        sha256_64bit = "sha256-p3gbLhwtZcZYCRTHbnntRU0ClF34RxHAMwcKCSqatJ0=";
        openSha256 = "0f0a6lr00pmigs4qzzymmnvpqwarg0rj1xv2zy0ais2r6ywb03fm";
        settingsSha256 = "0hm0h30kf0zs9zkwcqq6pm17zsr14v2pg0fg67y9y6n48fnpik20";
        persistencedSha256 = "1whxkxyd33771h8jd4rvhzdajrn43hnp6yfjanjd8nqa4ikwy5v4";
      };
    };
  };
}
