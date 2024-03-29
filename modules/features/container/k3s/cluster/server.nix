{ config
, lib
, ...
}: {
  imports = [ ./. ];
  # TODO testing
  networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 6443 ];
  services.k3s.extraFlags = toString [
    # "--cluster-init"
    "--write-kubeconfig-mode 0644"
    "--disable-etcd"
    # "--disable traefik"
    # "--flannel-backend=host-gw"
    # "--node-external-ip=10.241.3.1"
    # "--flannel-backend=wireguard-native"
    # "--flannel-external-ip"
    "--snapshotter=zfs"
    # TODO change
    # "--tls-san 10.241.3.1"
    "--node-ip 10.241.3.1"
    "--kube-proxy-arg=proxy-mode=ipvs"
    # "--bind-address 10.241.3.1"
    "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
  ];
  services.k3s.serverAddr = lib.mkDefault "https://10.241.2.1:6443";
  services.k3s.token = lib.mkDefault "K10587fcd071df338ba1a3501719ac1f04f201ed3779439aadc081240420c863183::server:9c5659b24b8f7eaf5120a92cef67b9d2";
}
