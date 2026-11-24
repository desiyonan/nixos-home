{ config, lib, pkgs, ... }:

let
  cfg = config.s01.cloudflareDDNS;
  target = builtins.toJSON (cfg // { provider = "Cloudflare"; settingsEditable = true; });
  apiStateDir = config.services.nixos-router.backend.managed.apiStateDir;
  disabledFile = "${apiStateDir}/cloudflare-ddns.disabled";
  checkEnabled = pkgs.writeShellScript "s01-cloudflare-ddns-enabled" ''
    marker=${lib.escapeShellArg disabledFile}
    [[ ! -e "$marker" && ! -L "$marker" ]]
  '';
  updater = pkgs.runCommand "s01-cloudflare-ddns" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    cp ${./update.py} update.py
    cp ${./test_update.py} test_update.py
    python3 -B test_update.py
    install -Dm644 update.py "$out/update.py"
  '';
in
{
  options.s01.cloudflareDDNS = {
    record = lib.mkOption {
      type = lib.types.strMatching "([a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+)?";
      default = "";
      description = "Initial DNS-only record. May also be set in the router DDNS page.";
    };
    recordType = lib.mkOption {
      type = lib.types.enum [ "A" "AAAA" ];
      description = "Address family of the DNS-only record.";
    };
    interface = lib.mkOption {
      type = lib.types.strMatching "[a-zA-Z0-9][a-zA-Z0-9_.-]{0,14}";
      description = "Interface from which to read a public IP address.";
    };
    intervalMinutes = lib.mkOption {
      type = lib.types.ints.between 1 1440;
      description = "Minutes between DDNS checks.";
    };
  };

  config = {
    assertions = [{
      assertion = builtins.stringLength cfg.record <= 253
        && lib.all (label: builtins.stringLength label <= 63) (lib.splitString "." cfg.record);
      message = "The DDNS record must fit the DNS name and label length limits.";
    }];
    systemd.services.nixos-router-backend.environment = {
      NIXOS_ROUTER_MANAGED_DDNS_CONFIG = target;
      NIXOS_ROUTER_MANAGED_DDNS_RECORD = cfg.record;
    };

    systemd.services.s01-cloudflare-ddns = {
      description = "Update the Cloudflare DNS-only record for ${cfg.record}";
      environment.NIXOS_ROUTER_MANAGED_DDNS_CONFIG = target;
      path = [ pkgs.iproute2 ];
      environment.SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      environment.NIXOS_ROUTER_DDNS_SETTINGS_FILE = "${apiStateDir}/ddns-settings.json";
      after = [ "nixos-router-state-init.service" ];
      wants = [ "nixos-router-state-init.service" ];
      serviceConfig = {
        Type = "oneshot";
        # The API owns its private settings file. The updater reads it without elevated privileges.
        User = "nixos-router-api";
        Group = "nixos-router-api";
        ExecCondition = checkEnabled;
        ExecStart = "${pkgs.python3}/bin/python3 -I ${updater}/update.py";
        TimeoutStartSec = "35s";
        # Provision this host-local file as root:root 0600, containing
        # {"zone_id": "...", "api_token": "..."} for DNS Write on dnfn.tech.
        LoadCredential = [ "cloudflare:/var/lib/cloudflare-ddns/credentials.json" ];
        # An empty default allows a fresh host to provision credentials from the page.
        SetCredential = [ "cloudflare:{}" ];
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        RestrictAddressFamilies = [ "AF_UNIX" "AF_NETLINK" "AF_INET" "AF_INET6" ];
      };
    };

    systemd.timers.s01-cloudflare-ddns = {
      description = "Periodically check the public address on ${cfg.interface}";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1min";
        OnUnitActiveSec = "${toString cfg.intervalMinutes}min";
        AccuracySec = "15s";
      };
    };
  };
}
