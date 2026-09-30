# Memorix Control Plane：HTTP MCP 单例，供 Cursor 等客户端共享连接
{ config, lib, ... }:

let
  cfg = config.modules.develop.memorix;
in
{
  options.modules.develop.memorix = {
    cliPath = lib.mkOption {
      type = lib.types.str;
      default = "/home/dnf/.npm-global/bin/memorix";
      description = "Absolute path to memorix CLI (npm global install).";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 3211;
      description = "HTTP MCP and dashboard port.";
    };
  };

  config = lib.mkIf (config.modules.develop.enable && cfg.enable) {
    systemd.user.services.memorix = {
      description = "Memorix Control Plane (HTTP MCP + dashboard)";
      after = [ "network.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = "${cfg.cliPath} serve-http --port ${toString cfg.port}";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
