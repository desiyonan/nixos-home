{
  name = "ws";
  system = "x86_64-linux";

  initrdMods = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  kernelMods = [ "kvm-intel" ];

  NICs = [ "wlp0s20f3" ];
  wifi = [ "wlp0s20f3" ];

  fs = {
    "/" = {
      device = "/dev/disk/by-uuid/18c5b20e-6a1b-4a57-8d17-5f2896e7a83a";
      fsType = "ext4";
    };
    "/nix" = {
      device = "/dev/disk/by-uuid/7a9e469e-1b7c-40bf-9053-492fe921a528";
      fsType = "ext4";
    };
    "/boot/efi" = {
      device = "/dev/disk/by-uuid/35AE-5282";
      fsType = "vfat";
    };
    "/data" = {
      device = "/dev/disk/by-uuid/57C1A6B90246AEF0";
      fsType = "ntfs-3g";
      # remove_hiberfile
    };
  };

  swap =[
    { device = "/dev/disk/by-uuid/af337d1b-bb00-4715-9b78-2b770dc9aec6"; }
  ];

  services = {
    # nvidia-offload.enable = true;
    nvidia-sync.enable = true;
    clash.enable = true;
    dockerd.enable =true;
  };

  groups = [ "manage" "develop" "gateway" "server" "worker" "edge" ];

  # powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
