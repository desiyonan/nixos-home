# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  nix.binaryCaches = [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    #"https://cache.nixos.org/"
  ];

  nix = {
    # binaryCaches = [
    # "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    # "https://mirrors.ustc.edu.cn/nix-channels/store"
    # "https://cache.nixos.org/"
    # ];
    # package = pkgs.nixVersions.stable;
    # extraOptions =
      # ''
        # experimental-features = nix-command flakes
      # '';
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    settings = {
      substituters = [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://mirrors.ustc.edu.cn/nix-channels/store"
      ];
    };
  };
  # nixpkgs.config.allowUnfree = true;
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    hostName = "ws";
    useDHCP = true;

    interfaces = {
      #  wlp0s20f3 = {
      #    useDHCP = true;
      #    name = "wlan0";
      #  };
       enp0s20f0u11u1 = {
         useDHCP = true;
         name = "eth0";
       };
       enp0s20f0u13u1 = {
         useDHCP = true;
         name = "eth1";
       };
    };
    # wireless = {
    #   enable = true;
    #   interfaces = [ "wlan0" ];
    #   networks = {
    #     Desiyonan = {
    #       psk = "DnF_PDCN15987532";
    #     };
    #     DnF_WL = {
    #       psk = "DnF_WF15987532";
    #       priority = 1;
    #     };
    #     DnF_WL_5G = {
    #       psk = "DnF_WF15987532";
    #     };
    #   };
    # };
  };


  # Select internationalisation properties.
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
  i18n = {
    supportedLocales = ["all"];
    defaultLocale = "zh_CN.utf8";

    inputMethod = {
      enabled = "fcitx5";
      # fcitx.engines = with pkgs.fcitx-engines; [ m17n ];
      fcitx5.addons = with pkgs; [ fcitx5-m17n fcitx5-chinese-addons ];
    };
  };

  # environment.variables = {
  #   INPUT_METHOD="fcitx";
  # };
  # environment.sessionVariables = {
  #   GTK_IM_MODULE = "fcitx";
  #   INPUT_METHOD="fcitx";
  #   QT_IM_MODULE = "fcitx";
  #   XMODIFIERS = "\@im=fcitx";
  # };

  # Enable the X11 windowing system.
  # Enable the Plasma 5 Desktop Environment.
  programs.xwayland.enable = true;
  # programs.qt5ct.enable = true;
  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
      desktopManager = {
        plasma5.enable = true;
        plasma5.runUsingSystemd = true;
      };
      displayManager = {
        # gdm.enable = true;
        sddm.enable = true;
        defaultSession = "plasmawayland";
      };
    };
  };
  # services = {
  #   zerotierone = {
  #     enable = true;
  #     joinNetworks = ["af78bf94369e9f0b"];
  #   };
  # };

  services.resolved = {
    enable = true;
    dnssec = "false";
    domains = [
      "dnfn.tech"
    ];
    fallbackDns = [
      "223.5.5.5"
      "223.6.6.6"
      "8.8.8.8"
      "2400:3200::1"
      "2400:3200:baba::1"
      # "192.168.123.251"
    ];
    # extraConfig =
    # ''
    #   DNS=192.168.123.251 192.168.123.1
    # '';
  };

  systemd = {
    network.enable = true;
  };
  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  #sound.enable = true;
  #hardware.pulseaudio.enable = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.prime = {
    #sync.enable = true;
    offload.enable = true;
    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    intelBusId = "PCI:0:2:0";
    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";
  };
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dnf = {
    # isNormalUser = true;
    isSuperUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    password = "passwd";
    initialPassword = "passwd";
    initialHashedPassword = "passwd";
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    firefox
    git
    # gh
    vscode
    # pciutils
    nvidia-offload
    # appimage-run
    # appimagekit
    # anydesk
    # bind
    # direnv
    # docker-client
    dhcp
    fzf
    # fcitx-configtool
    # fcitx5
    # fcitx5-chinese-addons
    # fcitx5-configtool
    # fcitx5-m17n
    # fcitx5-pinyin-zhwiki
    # fcitx5-pinyin-moegirl
    # fcitx5-with-addons
    # fcitx5-gtk
   #firefox
    # flameshot
    gcc
    glibc
    git
    # gh
    # go
    # google-chrome
    # gnome.gnome-keyring
    # jdk8
    # jdk11
    # jetbrains.idea-ultimate
    latte-dock
    ntfs3g

    # libsForQt5.fcitx5-qt
    # libsForQt5.krdc
    # libsForQt5.qt5.qtwayland

    htop
    hugo
    nix-index
    # p7zip
    refind
    tree
    # termius
    #softmaker-office #收费不好用
    unar
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.12"; # Did you read the comment?

}

