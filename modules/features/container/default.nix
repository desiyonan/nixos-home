{ pkgs, mpkgs, modulesPath, ... }:

{
  imports = [
    ./containerd
    ./docker
    # ./k8s
    # ./k3s
    ./k3s/cluster/server.nix
    # ./k3s/single.nix
    ./kubectl
    ./etcd
    ./helm
  ];

  environment.systemPackages = with pkgs; [
    rancher
  ];


}
