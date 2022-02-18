
{ config, pkgs, lib, makeWrapper, symlinkJoin, ... }:

with pkgs;
let
  config = ../../dotfiles/v2ray/config.json;
  env_asset = lib.last (builtins.match ".*V2RAY_LOCATION_ASSET (.*)\n.+" pkgs.v2ray.buildCommand);
  qv2ray-core = (symlinkJoin {
      name = "qv2ray-core";

      nativeBuildInput = [ makeWrapper ];

      paths = [
        pkgs.v2ray
        pkgs.qv2ray
      ];

      postInstall = ''
        ln -s ${env_asset} /run/current-system/sw/share/v2ray
      '';
    });
  
in
{
  # imports = [ qv2ray-config ];

  # networking = {
  #   proxy  = {
  #     allProxy = "socks5://localhost:1080";
  #     noProxy  = "127.0.0.1,localhost,desiyonan.tech";
  #   };
  # };

  environment.systemPackages = with pkgs; [
    v2ray
    qv2ray
    # qv2ray-core
  ];

  services = {
    v2ray = {
      enable = true;
      configFile = "${config}";
    };
  };

}
