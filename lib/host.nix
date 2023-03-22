{ system, pkgs, lib, user, mpkgs, nixpkgs, dotfiles, nixos-cn, ... }:
with builtins;
{
  mkHost = {
    name,
    initrdMods, kernelMods,
    fs,
    NICs,
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

    sys_users = (map (u: user.mkSystemUser u) users);
  in lib.nixosSystem {
    inherit system;
    specialArgs = { inherit pkgs mpkgs dotfiles; };
    modules = [
      nixpkgs.nixosModules.notDetected
      # (
      #   { config, pkgs, ...}:
      #   let
      #     overlay-mpkgs = final: prev: {
      #       mpkgs = mpkgs;
      #     };
      #   in
      #     {
      #       nixpkgs.overlays = [overlay-mpkgs];
      #     }
      # )
      {
        imports = [
          ../modules
          # ../features/common
          # 将nixos-cn flake提供的registry添加到全局registry列表中
          # 可在`nixos-rebuild switch`之后通过`nix registry list`查看
          nixos-cn.nixosModules.nixos-cn-registries

          # 引入nixos-cn flake提供的NixOS模块
          nixos-cn.nixosModules.nixos-cn
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

        hardware.opengl.enable = true;

        systemConfig = systemConfig;
        environment.systemPackages = systemPackages;

        networking.hostName = "${name}";
        networking.interfaces = networkCfg;
        networking.wireless.interfaces = wifi;

        networking.useDHCP = false;
        networking.networkmanager.enable = true;

        nixpkgs.pkgs = pkgs;
        nix.settings.max-jobs = lib.mkDefault cpuCores;

        services = services;
        features.enable = true;

        fileSystems = fs;
        swapDevices = swap;

        # system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
        system.stateVersion = "22.11";
      }
    ];
  };
}
