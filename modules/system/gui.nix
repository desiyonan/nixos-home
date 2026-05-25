{ config, lib, pkgs, ... }:

let
  cfg = config.modules.gui;
  nvidiaCfg = cfg.nvidia;
in
{
  options.modules.gui = {
    enable = lib.mkEnableOption "GUI desktop (Plasma 6 + SDDM on Wayland)";

    nvidia = {
      enable = lib.mkEnableOption "NVIDIA Prime sync (hybrid Intel + NVIDIA)";

      nvidiaBusId = lib.mkOption {
        type = lib.types.str;
        default = "PCI:1:0:0";
        description = "NVIDIA GPU bus ID (`lspci`, 3D or VGA section).";
      };

      intelBusId = lib.mkOption {
        type = lib.types.str;
        default = "PCI:0:2:0";
        description = "Intel GPU bus ID (`lspci`, 3D or VGA section).";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      modules.im.enable = lib.mkDefault true;

      programs.xwayland.enable = true;

      services.flatpak.enable = true;

      services = {
        desktopManager.plasma6.enable = true;
        displayManager = {
          sddm = {
            enable = true;
            wayland.enable = true;
          };
          defaultSession = "plasma";
        };
        xserver.enable = false;
      };

      environment.systemPackages = with pkgs; [
        plasma-panel-colorizer
        gparted
        chromium
        firefox
        google-chrome
      ];
    })

    (lib.mkIf (cfg.enable && nvidiaCfg.enable) {
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      hardware.nvidia = {
        open = false;
        modesetting.enable = true;
        nvidiaSettings = true;
        prime = {
          sync.enable = true;
          offload = {
            enable = false;
            enableOffloadCmd = false;
          };
          intelBusId = nvidiaCfg.intelBusId;
          nvidiaBusId = nvidiaCfg.nvidiaBusId;
        };
        package = config.boot.kernelPackages.nvidiaPackages.mkDriver rec {
          version = "580.126.18";
          url = "https://download.nvidia.com/XFree86/Linux-x86_64/${version}/NVIDIA-Linux-x86_64-${version}.run";
          sha256_64bit = "sha256-p3gbLhwtZcZYCRTHbnntRU0ClF34RxHAMwcKCSqatJ0=";
          openSha256 = "0f0a6lr00pmigs4qzzymmnvpqwarg0rj1xv2zy0ais2r6ywb03fm";
          settingsSha256 = "0hm0h30kf0zs9zkwcqq6pm17zsr14v2pg0fg67y9y6n48fnpik20";
          persistencedSha256 = "1whxkxyd33771h8jd4rvhzdajrn43hnp6yfjanjd8nqa4ikwy5v4";
        };
      };
    })
  ];
}
