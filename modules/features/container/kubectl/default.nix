{ pkgs,  modulesPath, ... }:

{

  environment.systemPackages =  with pkgs; [
    kubectl
  ];

}
