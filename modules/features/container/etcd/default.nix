{ pkgs,  modulesPath, ... }:

{

  environment.systemPackages =  with pkgs; [
    etcd
  ];

}
