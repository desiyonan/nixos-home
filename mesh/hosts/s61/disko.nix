# nixos-anywhere / disko：MBR/dos，vda1=/ ext4（含 /boot）、vda2=swap
{ lib, ... }:

{
  disko.devices.disk.disk1 = {
    device = lib.mkDefault "/dev/vda";
    type = "disk";
    content = {
      type = "table";
      format = "msdos";
      partitions = [
        {
          name = "root";
          start = "1M";
          end = "-1G";
          part-type = "primary";
          bootable = true;
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        }
        {
          name = "swap";
          start = "-1G";
          end = "100%";
          part-type = "primary";
          content = {
            type = "swap";
          };
        }
      ];
    };
  };
}
