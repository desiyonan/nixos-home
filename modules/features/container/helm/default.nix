{ pkgs,  modulesPath, ... }:

{
  environment.systemPackages =  with pkgs; [
    kubernetes-helm
  ];
}
