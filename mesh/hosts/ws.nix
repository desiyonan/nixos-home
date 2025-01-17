{
  name = "ws";
  system = "x86_64-linux";

  initrdMods = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "nvidia" ];
  kernelMods = [ "kvm-intel" "nvidia" ];

  NICs = [ "wlp0s20f3" ];
  wifi = [ "wlp0s20f3" ];

  fs = {

    "/boot/efi" =
    { device = "/dev/disk/by-uuid/6CD1-42EE";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

    # "/boot/efi" = {
    #  # device = "/dev/disk/by-uuid/4D9F-C385";
    #  device = "/dev/disk/by-uuid/35AE-5282";
    #  fsType = "vfat";
    #};

    "/" =
    { device = "/dev/disk/by-uuid/31543d1c-597c-4cf0-9331-16dd65a111ef";
      fsType = "ext4";
    };

    #"/" = {
      # device = "/dev/disk/by-uuid/10f9afd3-03b2-4724-adb1-914ea33964d7";
    #  device = "/dev/disk/by-uuid/5f96dbe8-faf5-4118-a690-5e5622ad6950";
    #  fsType = "ext4";
    #};
    #"/nix" = {
      # device = "/dev/disk/by-uuid/bcf85f76-8953-4897-a3d3-f1bbb6075950";
    #  device = "/dev/disk/by-uuid/97abe0dc-963d-4824-9b70-1f9faf3703d4";
    #  fsType = "ext4";
    #};
    "/data" = {
       #device = "/dev/disk/by-uuid/57C1A6B90246AEF0";
       #fsType = "ntfs-3g";
       # remove_hiberfile
       device = "/dev/disk/by-uuid/0174107f-5a48-43a9-b56c-c9f340657936";
       fsType = "ext4";
    };
  };

  swap =[
    # { device = "/dev/disk/by-uuid/a85e03cd-5822-40ee-88c6-62adba3b6d12"; }
    # { device = "/dev/disk/by-uuid/af337d1b-bb00-4715-9b78-2b770dc9aec6"; }
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
