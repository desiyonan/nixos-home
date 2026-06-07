{ config, lib, pkgs, ... }:

let
  cfg = config.modules.x3-ui;
  x3ui = pkgs.x3-ui;

  inherit (lib) optionalString;

  applySettings =
    let
      substitute = builtins.replaceStrings [
        "@yq@"
        "@dataDir@"
        "@xray@"
        "@x3ui@"
      ] [
        "${pkgs.yq}/bin/yq"
        cfg.dataDir
        "${pkgs.xray}"
        "${x3ui}"
      ];
    in
    pkgs.writeShellScript "x3-ui-apply-settings" (
      substitute (builtins.readFile ./apply-settings.sh)
    );

  overrideEnv = {
    OVERRIDE_PORT = optionalString (cfg.port != null) (toString cfg.port);
    OVERRIDE_USERNAME = optionalString (cfg.username != null) cfg.username;
    OVERRIDE_USERNAME_FILE =
      optionalString (cfg.usernameFile != null) (toString cfg.usernameFile);
    OVERRIDE_PASSWORD = optionalString (cfg.password != null) cfg.password;
    OVERRIDE_PASSWORD_FILE =
      optionalString (cfg.passwordFile != null) (toString cfg.passwordFile);
    OVERRIDE_LISTEN_IP = optionalString (cfg.listenIP != null) cfg.listenIP;
    OVERRIDE_WEB_BASE_PATH = optionalString (cfg.webBasePath != null) cfg.webBasePath;
    OVERRIDE_WEB_CERT = optionalString (cfg.webCert != null) (toString cfg.webCert);
    OVERRIDE_WEB_CERT_KEY = optionalString (cfg.webCertKey != null) (toString cfg.webCertKey);
    OVERRIDE_RESET_TWO_FACTOR = if cfg.resetTwoFactor then "true" else "";
    OVERRIDE_TG_ENABLE =
      if cfg.telegram.enable == true then
        "true"
      else if cfg.telegram.enable == false then
        "false"
      else
        "";
    OVERRIDE_TG_TOKEN = optionalString (cfg.telegram.token != null) cfg.telegram.token;
    OVERRIDE_TG_CHAT_ID = optionalString (cfg.telegram.chatId != null) cfg.telegram.chatId;
    OVERRIDE_TG_RUNTIME = optionalString (cfg.telegram.runtime != null) cfg.telegram.runtime;
  };

  effectivePort = if cfg.port != null then cfg.port else 31944;
in
{
  options.modules.x3-ui = {
    enable = lib.mkEnableOption "3x-ui Xray panel";

    settingsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/hosts/HOST/var/lib/3x-ui/settings.yaml";
      description = ''
        Optional YAML file whose keys are applied via `3x-ui setting` on each
        service start. Module-level options override values from this file.

        Supported keys: `port`, `username`, `password`, `usernameFile`,
        `passwordFile`, `listenIP`, `webBasePath`, `webCert`, `webCertKey`,
        `resetTwoFactor`, and nested `telegram` (`enable`, `token`, `chatId`,
        `runtime`).
      '';
    };

    port = lib.mkOption {
      type = lib.types.nullOr lib.types.port;
      default = null;
      description = ''
        Web panel port. Overrides [](#opt-modules.x3-ui.settingsFile); defaults
        to 31944 when unset in both places. Also used for the firewall.
      '';
    };

    username = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "admin";
      description = ''
        Panel login username. Overrides [](#opt-modules.x3-ui.settingsFile).
        Ignored when [](#opt-modules.x3-ui.usernameFile) is set.
      '';
    };

    usernameFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/hosts/HOST/var/lib/3x-ui/username";
      description = ''
        File containing the panel username. Overrides
        [](#opt-modules.x3-ui.settingsFile).
      '';
    };

    password = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Panel login password. Stored in the Nix store; prefer
        [](#opt-modules.x3-ui.passwordFile) or
        [](#opt-modules.x3-ui.settingsFile) for secrets.
      '';
    };

    passwordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/hosts/HOST/var/lib/3x-ui/password";
      description = ''
        File containing the panel password. Overrides
        [](#opt-modules.x3-ui.settingsFile).
      '';
    };

    listenIP = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "0.0.0.0";
      description = "Panel listen IP (`3x-ui setting -listenIP`).";
    };

    webBasePath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/panel/";
      description = "Panel URL base path (`3x-ui setting -webBasePath`).";
    };

    webCert = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "TLS certificate for the panel (`3x-ui setting -webCert`).";
    };

    webCertKey = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "TLS private key for the panel (`3x-ui setting -webCertKey`).";
    };

    resetTwoFactor = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Reset two-factor authentication on each service start.";
    };

    telegram = {
      enable = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Enable Telegram bot notifications (`-enabletgbot`).";
      };

      token = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Telegram bot token (`-tgbottoken`).";
      };

      chatId = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Telegram chat ID (`-tgbotchatid`).";
      };

      runtime = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "@daily";
        description = "Cron schedule for Telegram notifications (`-tgbotRuntime`).";
      };
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/3x-ui";
      description = "Directory to store 3x-ui data.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open firewall for the web panel port.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          cfg.settingsFile != null || cfg.password != null || cfg.passwordFile != null;
        message = "modules.x3-ui: set settingsFile, password, or passwordFile when the panel is enabled.";
      }
    ];

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
        SETTINGS_FILE =
          lib.optionalString (cfg.settingsFile != null) (toString cfg.settingsFile);
      }
      // overrideEnv;

      preStart = "${applySettings}";

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

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ effectivePort ];

    environment.systemPackages = [ x3ui ];
  };
}
