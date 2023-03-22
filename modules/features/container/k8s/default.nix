{ pkgs, mpkgs, modulesPath, ... }:

{
  environment.systemPackages =  with pkgs; [
    kubernetes
    kubernetes-helm
  ];
}
