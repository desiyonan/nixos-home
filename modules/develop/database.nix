{ config, lib, pkgs, ... }:

let
  cfg = config.modules.develop;
in
{
  config = lib.mkIf (cfg.enable && cfg.database.enable) {
    environment.systemPackages = with pkgs; [
      jetbrains.datagrip
      dbeaver-bin
      beekeeper-studio
      # redisinsight
      tableplus
      sqlfluff
      liquibase
    ];
  };
}
