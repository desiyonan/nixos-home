{ pkgs, mpkgs, modulesPath, ... }:

{

  environment.systemPackages =  with pkgs; [
    k3s
  ];
}
