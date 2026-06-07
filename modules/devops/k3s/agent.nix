{ config, lib, ... }:

let
  cfg = config.modules.devops;
in
{
  config = lib.mkIf (cfg.enable && cfg.k3s.enable && cfg.k3s.agent.enable) {
    services.k3s.role = "agent";
    services.k3s.tokenFile = "/run/secrets/programs/k3s/token";
    services.k3s.serverAddr = lib.mkDefault "https://10.241.9.1:6443";

    services.k3s.extraFlags = lib.concatStringsSep " " [
      "--write-kubeconfig-mode 0644"
      "--snapshotter=zfs"
      "--node-ip 10.241.3.1"
      "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
    ];
  };
}
