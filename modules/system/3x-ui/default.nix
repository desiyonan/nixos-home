{ config, lib, pkgs, ... }:

let
  cfg = config.modules.x3-ui;
  x3ui = pkgs.x3-ui;
in
{
  options.modules.x3-ui = {
    enable = lib.mkEnableOption "3x-ui Xray panel";

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/3x-ui";
      description = ''
        Directory for x-ui.db and runtime files. Panel settings (port, credentials,
        TLS paths, inbounds) are read only from the database; provision it via
        secret-hub bind mount or other means, and update the encrypted snapshot
        in secrets to change initial state.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.x3-ui = {
      isSystemUser = true;
      group = "x3-ui";
      description = "3x-ui service user";
    };

    users.groups.x3-ui = { };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 x3-ui x3-ui -"
      "d ${cfg.dataDir}/bin 0755 x3-ui x3-ui -"
      "d ${cfg.dataDir}/logs 0755 x3-ui x3-ui -"
    ];

    systemd.services.x3-ui = {
      description = "3x-ui Xray Panel";
      after = [ "network.target" "sops-nix.service" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        XUI_DB_FOLDER = cfg.dataDir;
        XUI_BIN_FOLDER = "${cfg.dataDir}/bin";
        XUI_LOG_FOLDER = "${cfg.dataDir}/logs";
      };

      preStart = "${pkgs.writeShellScript "x3-ui-prestart" ''
        set -euo pipefail
        mkdir -p ${cfg.dataDir}/bin ${cfg.dataDir}/logs
        ln -sf ${pkgs.xray}/bin/xray ${cfg.dataDir}/bin/xray-linux-amd64
      ''}";

      serviceConfig = {
        Type = "simple";
        ExecStart = "${x3ui}/bin/3x-ui";
        WorkingDirectory = cfg.dataDir;
        Restart = "on-failure";
        RestartSec = "10s";
        PermissionsStartOnly = true;
        User = "x3-ui";
        Group = "x3-ui";
        StateDirectory = "3x-ui 3x-ui/bin 3x-ui/logs";
        StateDirectoryMode = "0755";
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" "CAP_NET_ADMIN" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" "CAP_NET_ADMIN" ];
      };
    };

    environment.systemPackages = [ x3ui ];
  };
}
