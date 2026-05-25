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
    services.k3s.token = lib.mkDefault
      "K10587fcd071df338ba1a3501719ac1f04f201ed3779439aadc081240420c863183::server:9c5659b24b8f7eaf5120a92cef67b9d2";
  };
}
