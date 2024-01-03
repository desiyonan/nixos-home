{ pkgs,
  nixpkgs,
  ...
}:
with pkgs;
with builtins;
{
  mkHost = {
    name,
    initrdMods,
    kernelMods,
    fs,
    NICs,
    system,
    systemConfig ? {},
    systemPackages ? [],
    services ? {},
    kernelPackage ? pkgs.linuxPackages_latest,
    kernelParams ? [],
    swap? [],
    cpuCores ? 4,
    wifi ? []
  }: users:

  let
    networkCfg = listToAttrs (map (n: {
      name = "${n}";
      value = { useDHCP = true; };
    }) NICs);

    sys_users = (map (u: lib.mkSystemUser u) users);
  in nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = {
      inherit pkgs;
      mpkgs = pkgs.mpkgs;
    };
    modules = [
      nixpkgs.nixosModules.notDetected
      {
        imports = [
          ../modules
          ../modules/services
          # 将nixos-cn flake提供的registry添加到全局registry列表中
          # 可在`nixos-rebuild switch`之后通过`nix registry list`查看
          # nixos-cn.nixosModules.nixos-cn-registries

          # 引入nixos-cn flake提供的NixOS模块
          # nixos-cn.nixosModules.nixos-cn
        ] ++ sys_users;

        hardware.enableRedistributableFirmware = lib.mkDefault true;

        boot.initrd.availableKernelModules = initrdMods;
        boot.kernelModules = kernelMods;
        boot.kernelParams = kernelParams;
        boot.kernelPackages = kernelPackage;
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

        nix.settings.max-jobs = lib.mkDefault cpuCores;

        # services = services;

        fileSystems = fs;
        swapDevices = swap;

        # system.stateVersion = "22.11";
      }
    ];
  };
}
