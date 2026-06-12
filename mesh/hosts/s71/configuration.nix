{ pkgs, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # 1GB KVM VPS：不拉全量 firmware，仅 ext4（见 disko.nix）
  hardware.enableAllFirmware = false;
  hardware.enableRedistributableFirmware = false;
  boot.supportedFilesystems.zfs = false;
  boot.supportedFilesystems.bcachefs = false;

  # BIOS/MBR VPS（无 EFI）；/boot 在根分区上（见 disko.nix MBR 布局）
  boot.loader.grub = {
    enable = true;
    device = lib.mkDefault "/dev/vda";
  };

  networking = {
    hostName = "srimsiuh-71";
    enableIPv6 = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 443 ];
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  environment.systemPackages = with pkgs; [
    curl
    git
    vim
  ];

  system.stateVersion = "26.05";
}
