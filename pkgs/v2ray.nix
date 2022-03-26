
{ config, pkgs, lib, dotfiles, ... }:

with pkgs;
let
  config = dotfiles.v2ray.conf;
  env_asset = lib.last (builtins.match ".*V2RAY_LOCATION_ASSET (.*)\n.+" pkgs.v2ray.buildCommand);
  qv2ray-core = (pkgs.symlinkJoin {
      name = "qv2ray-core";

      nativeBuildInput = [ ];

      paths = [
        pkgs.v2ray
      ];

      postInstall = ''
        mk -p /run/current-system/sw/share/v2ray
        ln -s ${env_asset} /run/current-system/sw/share/v2ray
      '';
    });
in
{

  # networking = {
  #   proxy  = {
  #     allProxy = "socks5://localhost:1080";
  #     noProxy  = "127.0.0.1,localhost,desiyonan.tech";
  #   };
  # };

  environment.systemPackages = [
    pkgs.v2ray
    pkgs.qv2ray
    # qv2ray-core
  ];

  services = {
    v2ray = {
      enable = true;
      configFile = "${config}";
    };
  };

}
