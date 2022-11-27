{
  name = "ws";

  initrdMods = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  kernelMods = [ "kvm-intel" ];

  NICs = [ "wlp0s20f3" ];
  wifi = [ "wlp0s20f3" ];

  fs = {
    "/" =
    { device = "/dev/disk/by-uuid/98ea2a72-1ef8-4449-b08d-698ca3e135df";
      fsType = "ext4";
    };
    "/boot/efi" =
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
