
{ pkgs, lib, dotfiles, ... }:

with pkgs;
let
  config = dotfiles.v2ray.conf;
  # env_asset = lib.last (builtins.match ".*V2RAY_LOCATION_ASSET (.*)\n.+" pkgs.v2ray.buildCommand);
in
pkgs.symlinkJoin {
    name = "qv2ray-full";

    paths = [
      # env_asset
      v2ray-geoip
      v2ray-domain-list-community
      pkgs.v2ray
      pkgs.qv2ray
    ];

    # postBuild = ''
    #   mkdir -p $out/share/v2ray
    #   mv $out/geo* $out/share/v2ray
    # '';
  }
