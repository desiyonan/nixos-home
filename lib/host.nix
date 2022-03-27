{ system, pkgs, lib, user, mpkgs, ... }:
with builtins;
{
  mkHost = {
    name,
    initrdMods, kernelMods,
    fs,
    NICs,
    systemConfig,
    users,
    kernelPackage ? pkgs.linuxPackages_latest,
    kernelParams ? [],
    swap? [],
    cpuCores ? 4,
    wifi ? []
  }:

  let
    networkCfg = listToAttrs (map (n: {
      name = "${n}";
      value = { useDHCP = true; };
    }) NICs);

    sys_users = (map (u: user.mkSystemUser u) users);
  in lib.nixosSystem {
    inherit system;
    specialArgs = { inherit pkgs mpkgs dotfiles; };
    modules = [
      {
        imports = [
          # (modulesPath + "/installer/scan/not-detected.nix")
          ../features/common
        ] ++ sys_users;
        hardware.enableRedistributableFirmware = lib.mkDefault true;

        boot.initrd.availableKernelModules = initrdMods;
        boot.kernelModules = kernelMods;
        boot.kernelParams = kernelParams;
        boot.kernelPackages = kernelPackage;
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        # jd = systemConfig;

        networking.hostName = "${name}";
        networking.interfaces = networkCfg;
        networking.wireless.interfaces = wifi;

        networking.useDHCP = false;
        networking.networkmanager.enable = true;

        nixpkgs.pkgs = pkgs;
        nix.settings.max-jobs = lib.mkDefault cpuCores;

        fileSystems = fs;
        swapDevices = swap;

        system.stateVersion = "21.05";
      }
    ];
  };
}
