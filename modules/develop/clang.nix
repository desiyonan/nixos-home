{ config, lib, pkgs, ... }:

let
  cfg = config.modules.develop;
in
{
  config = lib.mkIf (cfg.enable && cfg.clang.enable) {
    environment.systemPackages = with pkgs; [ ];
  };
}
