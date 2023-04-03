{ pkgs, mpkgs, modulesPath, ... }:

{

  environment.systemPackages =  with pkgs; [
    nerdctl
    containerd
  ];
  virtualisation.containerd.enable = true;

}
