{ pkgs, mpkgs, modulesPath, system, ... }:

{
  # This is required so that pod can reach the API server (running on port 6443 by default)
  networking.firewall.allowedTCPPorts = [ 6443 ];
  services.k3s.enable = true;
  services.k3s.role = "server";
  services.k3s.extraFlags = toString [
    # "--kubelet-arg=v=4" # Optionally add additional args to k3s
    "--cluster-init"
    "--write-kubeconfig-mode 0644"
    "--disable traefik"
    "--flannel-backend=host-gw"
    # "--node-external-ip=10.241.3.1"
    # "--flannel-backend=wireguard-native"
    # "--flannel-external-ip"
    # "--snapshotter=zfs"
    # TODO change
    "--tls-san 10.241.3.1"
    "--node-ip 10.241.3.1"
    "--bind-address 10.241.31.1"
    # "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
  ];
  environment.systemPackages = [ pkgs.k3s ];
}
