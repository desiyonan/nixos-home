{ pkgs, mpkgs, modulesPath, ... }:

{
  imports = [
    ./docker-cli
    ./k8s
    ./k3s
    ./etcd
  ];

  environment.systemPackages = with pkgs; [
    rancher
  ];


}
