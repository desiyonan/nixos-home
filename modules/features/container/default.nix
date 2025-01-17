{ pkgs, modulesPath, ... }:

{
  imports = [
    ./containerd
    ./docker
    # ./k8s
    # ./k3s
    # ./k3s/cluster/leader.nix
    # ./k3s/cluster/server.nix
    # ./k3s/cluster/agent.nix
    # ./k3s/single.nix
    ./kubectl
    ./etcd
    ./helm
    # ./waydroid
  ];

  environment.systemPackages = with pkgs; [
    rancher
  ];


}
