{ pkgs, modulesPath, ... }:

{
  environment.systemPackages =  with pkgs; [
    awscli2
    aws-sam-cli
  ];
}
