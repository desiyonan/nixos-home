{ config, lib, pkgs, ... }:

let
  cfg = config.modules.develop;
in
{
  config = lib.mkIf (cfg.enable && cfg.javascript.enable) {
    environment.systemPackages = with pkgs; [
      nodejs
      biome
      prettier
      codex
      claude-code
    ] ++ [
      pkgs."@colbymchenry/codegraph"
    ];
  };
}
