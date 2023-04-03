{ pkgs, mpkgs, modulesPath, ... }:

{
  environment.systemPackages =  with pkgs; [
    kubernetes-helm
  ];
}
