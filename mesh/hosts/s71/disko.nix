# infect 后 VPS 布局：MBR/dos，vda1=/ ext4（含 /boot）、vda2=swap，无独立 /boot
# 新装时按此分区；已有盘 switch 时作声明式挂载参考（勿改分区尺寸除非整盘重装）
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
