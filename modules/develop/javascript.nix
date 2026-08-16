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
      unstable.codex
      claude-code
      unstable.opencode
      unstable.opencode-desktop
      unstable.pi-coding-agent
    ] ++ [
      pkgs."@colbymchenry/codegraph"
    ];
  };
}
