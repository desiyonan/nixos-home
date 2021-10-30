{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "wl";
    useDHCP = true;
    interfaces.enp33s0.useDHCP = true;
    extraHosts =
    ''
    192.168.123.251 ds.dnfn.tech oss.dnfn.tech
    '';
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/1c9802aa-054b-48f7-bc42-13fcc6b62a95";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/8CDA-B74B";
      fsType = "vfat";
    };

  swapDevices = [ ];

  system.stateVersion = "21.05"; # Did you read the comment?
}
