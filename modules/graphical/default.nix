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
      enable = lib.mkEnableOption "NVIDIA Prime offload（Intel 出图 + NVIDIA 按需；Wayland 推荐）";

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
      # todesk：nixpkgs 源走 archive.org，常 429；官网 CDN 有反爬，暂不可构建
      # services.todesk.enable = true;
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
        gImageReader
        normcap
        todoist-electron
        librecad
        freecad-wayland
        libsForQt5.qt5.qtwayland
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

      # 唤醒时勿冻结用户会话，避免 KWin 抢不到 DRM（NixOS Wiki / discourse #54341）
      systemd.services.systemd-suspend.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
      systemd.services.systemd-hibernate.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
      systemd.services.systemd-suspend-then-hibernate.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";

      # s2h 不走 systemd-suspend：首阶段需 nvidia-suspend，收尾需 nvidia-resume（VT 切换）
      systemd.services.nvidia-suspend = {
        before = [ "systemd-suspend-then-hibernate.service" ];
        requiredBy = [ "systemd-suspend-then-hibernate.service" ];
      };
      systemd.services.nvidia-resume = {
        after = [ "systemd-suspend-then-hibernate.service" ];
        requiredBy = [ "systemd-suspend-then-hibernate.service" ];
      };

      # NixOS 未把 systemd.packages 的 system-sleep 装进 /etc；s2h 中段进 hibernate 靠此 hook。
      # stock hook 的 post 会调 nvidia-sleep.sh，但 PATH 无 kbd → chvt 失败，且先删掉
      # /var/run/nvidia-sleep/Xorg.vt_number，导致随后 nvidia-resume 无法切回图形 TTY。
      environment.etc."systemd/system-sleep/nvidia".source =
        let
          upstream = "${config.hardware.nvidia.package}/lib/systemd/system-sleep/nvidia";
        in
        pkgs.writeShellScript "nvidia-system-sleep" ''
          export PATH="${pkgs.kbd}/bin:${pkgs.kbd}/sbin''${PATH:+:$PATH}"
          exec ${pkgs.runtimeShell} ${upstream} "$@"
        '';

      # 显存快照落到磁盘；空路径时驱动默认 /tmp（虽本机 /tmp 非 tmpfs，仍更稳妥）
      boot.kernelParams = [
        "nvidia.NVreg_TemporaryFilePath=/var/tmp"
      ];

      hardware.nvidia = {
        open = false;
        modesetting.enable = true;
        nvidiaSettings = true;
        # 睡眠保留显存 + nvidia-suspend/resume
        powerManagement.enable = true;
        # Wayland 下 sync 无效；内屏已在 Intel(eDP)。offload：Intel 出图，NVIDIA 按需
        # 日志：resume 后 Failed to open /dev/dri/card0 → Atomic modeset 权限不够 → 黑屏
        prime = {
          sync.enable = false;
          offload = {
            enable = true;
            enableOffloadCmd = true;
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
