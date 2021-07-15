{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "hy";

  networking.useDHCP = false;
  # networking.interfaces.enp33s0.useDHCP = true;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/86725f42-453a-4388-961c-e98455f8696b";
      fsType = "ext4";
    };

  fileSystems."/opt" =
    { device = "/dev/disk/by-uuid/aae295df-f7d4-46ee-bf42-3c1a7f463b46";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/7B0C-592B";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/4c98ebf3-6a3c-4922-ad23-e230ca1640ed"; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  system.stateVersion = "21.05"; # Did you read the comment?
}
