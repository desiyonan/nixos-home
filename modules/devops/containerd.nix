{ config, lib, pkgs, ... }:

let
  cfg = config.modules.devops;
in
{
  config = lib.mkIf (cfg.enable && cfg.containerd.enable) {
    virtualisation.containerd.enable = true;

    environment.systemPackages = with pkgs; [
      nerdctl
      containerd
    ];
  };
}
