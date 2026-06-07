{ config, lib, ... }:

let
  cfg = config.modules.devops;
in
{
  config = lib.mkIf (cfg.enable && cfg.k3s.enable && cfg.k3s.server.enable) {
    networking.firewall.enable = false;
    networking.firewall.allowedTCPPorts = [ 6443 ];

    services.k3s.extraFlags = lib.concatStringsSep " " [
      "--write-kubeconfig-mode 0644"
      "--disable-etcd"
      "--snapshotter=zfs"
      "--node-ip 10.241.3.1"
      "--kube-proxy-arg=proxy-mode=ipvs"
      "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
    ];

    services.k3s.serverAddr = lib.mkDefault "https://10.241.2.1:6443";
    services.k3s.tokenFile = lib.mkDefault "/run/secrets/programs/k3s/token";
  };
}
