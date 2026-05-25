{ config, lib, pkgs, ... }:

let
  cfg = config.modules.devops;
in
{
  config = lib.mkIf (cfg.enable && cfg.aws.enable) {
    environment.systemPackages = with pkgs; [
      awscli2
      aws-sam-cli
    ];
  };
}
