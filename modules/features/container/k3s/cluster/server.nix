{ ...
}: {
  imports = [ ./. ];
  # TODO testing
  networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 6443 ];
  # services.k3s.extraFlags = "--disable traefik --flannel-backend=host-gw --snapshotter=zfs --container-runtime-endpoint unix:///run/containerd/containerd.sock";
  services.k3s.extraFlags = toString [
    "--cluster-init"
    "--write-kubeconfig-mode 0644"
    "--write-kubeconfig /root/.kube/config"
    "--disable traefik"
    "--flannel-backend=host-gw"
    # "--node-external-ip=10.241.6.1"
    # "--flannel-backend=wireguard-native"
    # "--flannel-external-ip"
    "--snapshotter=zfs"
    # TODO change
    "--tls-san 10.241.6.1"
    "--node-ip 10.241.6.1"
    "--bind-address 10.241.6.1"
    "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
  ];
  # services.k3s.serverAddr = "https://10.241.1.1:6443";
  # services.k3s.token = "";
}
