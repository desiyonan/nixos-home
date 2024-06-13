{ pkgs,  modulesPath, ... }:

{
  environment.systemPackages =  with pkgs; [
    kubernetes
    kubernetes-helm
    minikube
  ];
}
