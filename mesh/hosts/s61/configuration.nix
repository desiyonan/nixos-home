{ pkgs, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  hardware.enableAllFirmware = false;
  hardware.enableRedistributableFirmware = false;
  boot.supportedFilesystems.zfs = false;
  boot.supportedFilesystems.bcachefs = false;

  boot.loader.grub = {
    enable = true;
    device = lib.mkDefault "/dev/vda";
  };

  networking = {
    hostName = "srimsiuh-61";
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
