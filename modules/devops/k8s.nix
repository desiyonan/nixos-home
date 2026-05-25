{ config, lib, pkgs, ... }:

let
  cfg = config.modules.devops;
in
{
  config = lib.mkIf (cfg.enable && cfg.k8s.enable) {
    environment.systemPackages = with pkgs; [
      kubernetes
      kubernetes-helm
      minikube
    ];
  };
}
