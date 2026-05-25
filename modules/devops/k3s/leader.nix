{ config, lib, ... }:

let
  cfg = config.modules.devops;
in
{
  config = lib.mkIf (cfg.enable && cfg.k3s.enable && cfg.k3s.leader.enable) {
    networking.firewall.enable = false;
    networking.firewall.allowedTCPPorts = [ 6443 ];

    services.k3s.extraFlags = lib.concatStringsSep " " [
      "--cluster-init"
      "--write-kubeconfig-mode 0644"
      "--disable traefik"
      "--flannel-backend=host-gw"
      "--snapshotter=zfs"
      "--tls-san 10.241.3.1"
      "--node-ip 10.241.3.1"
      "--bind-address 10.241.3.1"
      "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
    ];
  };
}
