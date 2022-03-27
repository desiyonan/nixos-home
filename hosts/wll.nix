{
  name = "wl";

  initrdMods = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  kernelMods = [ "kvm-amd" ];

  fs={
    "/" = {
      device = "/dev/disk/by-uuid/1c9802aa-054b-48f7-bc42-13fcc6b62a95";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/8CDA-B74B";
      fsType = "vfat";
    };
  };

  # networking = {
  #   # useDHCP = true;
  #   interfaces.enp33s0.useDHCP = true;
  #   extraHosts =
  #   ''
  #   192.168.123.251 ds.dnfn.tech oss.dnfn.tech
  #   '';
  # };
  NICs = [ "enp33s0" ];

  systemConfig = [];
}
