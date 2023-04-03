{ pkgs, mpkgs, modulesPath, ... }:

{

  environment.systemPackages =  with pkgs; [
    kubectl
  ];

}
