{ config
, lib
, ...
}: {
  imports = [ ./. ];

#   sops.secrets.k3s-server-token.sopsFile = ./secrets.yml;
  services.k3s.role = "agent";
  # generated random string
  # services.k3s.tokenFile = lib.mkDefault config.sops.secrets.k3s-server-token.path;
  # services.k3s.serverAddr = lib.mkDefault "https://dc.dnfn.tech:6443";
  services.k3s.token = "K106844a05dc03df53c2985503869f093ee3be3821ae96738434b183e1872a23315::server:4b733fdde2c3b26bd5ba32f5678c6358";
  services.k3s.serverAddr = lib.mkDefault "https://10.241.9.1:6443";
  # TODO change
   services.k3s.extraFlags = toString [
    # "--cluster-init"
    "--write-kubeconfig-mode 0644"
    # "--disable traefik"
    # "--flannel-backend=host-gw"
    # "--node-external-ip=10.241.3.1"
    # "--flannel-backend=wireguard-native"
    # "--flannel-external-ip"
    "--snapshotter=zfs"
    # TODO change
    # "--tls-san 10.241.3.1"
    "--node-ip 10.241.3.1"
    # "--bind-address 10.241.3.1"
    "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
  ];
}
