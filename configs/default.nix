{
  name,
  initrdMods,
  kernelMods,
  fs,
  NICs,
  system,
  groups ? [],
  systemConfig ? {},
  systemPackages ? [],
  services ? {},
  # kernelPackage ? (import <nixos-unstable> {}).linuxPackages_latest,
  kernelParams ? [],
  swap? [],
  cpuCores ? 4,
  wifi ? [],
  ...
}:

{pkgs, lib, root_inputs, ...}:
let
  networkCfg = builtins.listToAttrs (map (n: {
    name = "${n}";
    value = { useDHCP = true; };
  }) NICs);
in
# root_inputs.flake-utils.lib.eachDefaultSystem (system:
{
  imports = [
    # ../overlays
    ../modules
    # 将nixos-cn flake提供的registry添加到全局registry列表中
    # 可在`nixos-rebuild switch`之后通过`nix registry list`查看
    # nixos-cn.nixosModules.nixos-cn-registries

    # 引入nixos-cn flake提供的NixOS模块
    # nixos-cn.nixosModules.nixos-cn
  ];

  # hardware.enableRedistributableFirmware = lib.mkDefault true;
  nixpkgs.hostPlatform = "x86_64-linux";

  boot.initrd.availableKernelModules = initrdMods;
  boot.kernelModules = kernelMods;
  boot.kernelParams = kernelParams;
  # boot.kernelPackages = kernelPackage;
  boot.loader = {
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi"; # ← use the same mount point here.
    };
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # systemConfig = systemConfig;
  environment.systemPackages = systemPackages;

  networking.hostName = "${name}";
  networking.interfaces = networkCfg;
  networking.wireless.interfaces = wifi;

  networking.useDHCP = false;
  networking.networkmanager.enable = true;

  # nix.settings.max-jobs = lib.mkDefault cpuCores;
  nix.settings.max-jobs = cpuCores;

  # services = services;
  inherit services;

  fileSystems = fs;
  swapDevices = swap;

  # system.stateVersion = "23.11";
}
# )
