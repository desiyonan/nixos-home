{ config, pkgs,  lib, ... }:
with lib;

let
  cfg = config.services.kuro;
in {
  options.services.kuro = {
    enable = mkOption {
      description = "Wether enable Kuro service";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf(cfg.enable) {
    environment.systemPackages = with pkgs; [
      kuro
    ];

    systemd.user.services.kuro = {
      enable = true;
      description = "Kuro service";
      script = "${pkgs.kuro}/bin/kuro";
      serviceConfig = {
        Type="simple";
        Restart = "always";
        RestartSec = 3;
      };
      wantedBy = [ "default.target" ];
    };
  };
}
