# 图形化模块：Plasma 6 + SDDM Wayland
{ config, lib, pkgs, ... }:

let
  cfg = config.modules.graphical;
  nvidiaCfg = cfg.nvidia;
in
{
  options.modules.graphical = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "图形化桌面（Plasma 6 + SDDM Wayland）";
    };

    nvidia = {
      enable = lib.mkEnableOption "NVIDIA Prime sync（Intel + NVIDIA 混显）";

      nvidiaBusId = lib.mkOption {
        type = lib.types.str;
        default = "PCI:1:0:0";
        description = "NVIDIA GPU bus ID（`lspci` 3D/VGA）";
      };

      intelBusId = lib.mkOption {
        type = lib.types.str;
        default = "PCI:0:2:0";
        description = "Intel GPU bus ID（`lspci` 3D/VGA）";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      modules.im.enable = lib.mkDefault true;
      modules.multimedia.enable = lib.mkDefault true;
      modules.bluetooth.enable = lib.mkDefault true;

      programs.xwayland.enable = true;

      services.flatpak.enable = true;
      services.todesk.enable = true;
      services.fwupd.enable = true;
      services.hardware.bolt.enable = true;

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

        # 图形化 / 桌面应用
        kdePackages.ark
        appimage-run
        anydesk
        blender
        kdePackages.filelight
        flameshot
        kdiff3
        kdePackages.kompare
        lightworks
        obs-studio
        wechat-uos
        redli
        scrcpy
        thunderbird
        kdePackages.plasma-thunderbolt
        wpsoffice
        vlc
        waveterm
        warp-terminal
        gui-for-singbox
        gImageReader
        normcap
        todoist-electron
        librecad
        freecad-wayland
        libsForQt5.qt5.qtwayland
        todesk
        waybar

        # 不常用 / 偏工作站（自 base 迁入）
        adbfs-rootless
        android-tools
        xclip
        wl-clipboard
        freerdp
        opencv
        pulseaudioFull
        pipewire
        refind
        linux-wifi-hotspot
        qemu_kvm
        libredwg
        freetype
        tesseract
        distrobox
        thunderbolt
        bolt
        webcat
        hugo
        mutt

        # 原 base/packages.nix
        bzip2
        bind
        bat
        dust
        gnumake
        cmake
        clang
        gcc
        gdb
        lsof
        lshw
        llvmPackages.clangUseLLVM
        llvmPackages.libclang
        direnv
        iptables
        nix-direnv
        dog
        duf
        envsubst
        fzf
        fd
        ripgrep
        fx
        git-lfs
        glibc
        ntfs3g
        openiscsi
        inetutils
        jq
        htop
        httpie
        hexyl
        mcfly
        ncdu
        nix-index
        openssl
        pkg-config
        p7zip
        pciutils
        procs
        sops
        tree
        tmux
        unar
        vim
        wget
        zip
        patchelf
        usbutils
        glab
        recode
        dhcpcd
      ];

      services.openiscsi = {
        enable = false;
        name = "iqn.2020-08.org.linux-iscsi.initiatorhost:ws";
      };
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
