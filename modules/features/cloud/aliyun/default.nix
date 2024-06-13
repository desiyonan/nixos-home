{ pkgs,  modulesPath, ... }:

{
  environment.systemPackages =  with pkgs; [
    aliyun-cli
  ];
}
