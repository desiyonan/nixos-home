{ config, lib, pkgs, ... }:

let
  cfg = config.modules.devops;
in
{
  config = lib.mkIf (cfg.enable && cfg.k3s.enable && cfg.k3s.single.enable) {
    networking.firewall.allowedTCPPorts = [ 6443 ];

    services.k3s = {
      enable = true;
      role = "server";
      extraFlags = lib.concatStringsSep " " [
        "--cluster-init"
        "--write-kubeconfig-mode 0644"
        "--disable traefik"
        "--flannel-backend=host-gw"
        "--tls-san 10.241.3.1"
        "--node-ip 10.241.3.1"
        "--bind-address 10.241.31.1"
      ];
    };

    environment.systemPackages = [ pkgs.k3s ];
  };
}
