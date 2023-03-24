{ pkgs, mpkgs, modulesPath, ... }:

{
  environment.systemPackages =  with pkgs; [
    aliyun-cli
  ];
}
