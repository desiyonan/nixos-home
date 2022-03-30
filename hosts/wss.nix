{
  name = "ws";

  initrdMods = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  kernelMods = [ "kvm-intel" ];

  NICs = [ "wlp0s20f3" "enp0s20f0u11u1" "enp0s20f0u13u1"];
  wifi = [ "wlp0s20f3" ];

  fs = {
    "/" =
    { device = "/dev/disk/by-uuid/7aaabf7b-8b28-4feb-b60a-81cb35968663";
      fsType = "ext4";
    };
    "/boot" =
    { device = "/dev/disk/by-uuid/FA49-7E4A";
      fsType = "vfat";
    };
    "/data" =
    { device = "/dev/disk/by-uuid/09C1B27DA5EB573A";
      fsType = "ntfs-3g";
    };
  };
  swap =
  [ { device = "/dev/disk/by-uuid/e9a24aef-1fac-45ef-af49-aba05e2426f9"; }
  ];

  # powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
