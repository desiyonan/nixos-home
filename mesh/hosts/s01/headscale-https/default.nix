{ config, lib, ... }:

let
  cfg = config.s01.headscaleHttps;
  inherit (cfg) domain;
  certName = if cfg.production then "headscale-service" else "headscale-service-staging";
  cert = config.security.acme.certs.${certName};
  certGroup = "s01-headscale-tls";
  baseUnit = "acme-${certName}.service";
  orderUnit = "acme-order-renew-${certName}.service";
  upstream = "http://${config.services.headscale.address}:${toString config.services.headscale.port}";
  forwardHeaders = ''
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto https;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header True-Client-IP "";
    proxy_set_header Forwarded "";
    proxy_set_header Authorization "";
  '';
in
{
  options.s01.headscaleHttps = {
    domain = lib.mkOption {
      type = lib.types.str;
      default = "hs.dnfn.tech";
      readOnly = true;
      description = "Stable DNS name for the Headscale control service.";
    };
    enableACME = lib.mkEnableOption "DNS-01 certificate issuance and renewal for s01 Headscale";
    production = lib.mkEnableOption "the production ACME CA instead of staging";
    enableProxy = lib.mkEnableOption "the loopback-only TLS proxy for s01 Headscale";
    publicPort = lib.mkOption {
      type = lib.types.nullOr lib.types.port;
      default = null;
      description = "Optional public IPv4 HTTPS port for the Headscale proxy.";
    };
  };

  config = lib.mkMerge [
    {
      assertions = [{
        assertion = !cfg.enableProxy || cfg.enableACME;
        message = "s01.headscaleHttps.enableProxy requires s01.headscaleHttps.enableACME.";
      } {
        assertion = cfg.publicPort == null || (cfg.enableProxy && cfg.production && cfg.publicPort > 0 && cfg.publicPort != 18443);
        message = "The public Headscale listener requires the production proxy and a separate port.";
      }];
    }

    (lib.mkIf (cfg.publicPort != null) {
      services.nixos-router.backend.managed.wanTCPPorts = [ cfg.publicPort ];
    })

    (lib.mkIf cfg.enableACME {
      security.acme = {
        acceptTerms = true;
        certs.${certName} = {
          inherit domain;
          inheritDefaults = false;
          server = if cfg.production
            then "https://acme-v02.api.letsencrypt.org/directory"
            else "https://acme-staging-v02.api.letsencrypt.org/directory";
          dnsProvider = "cloudflare";
          dnsPropagationCheck = true;
          enableDebugLogs = false;
          # Zone:Read and DNS:Edit for dnfn.tech. Provision as root:root 0600.
          # This file holds only the ACME token and is separate from DDNS.
          credentialFiles.CF_DNS_API_TOKEN_FILE = "/var/lib/s01-headscale-acme/cloudflare-token";
          group = certGroup;
          reloadServices = lib.optional cfg.enableProxy "nginx.service";
        };
      };

      users.groups.${certGroup} = { };

      # Avoid retaining third-party API error bodies in the journal. systemd
      # still records the unit's exit status and credential loading failures.
      systemd.services."acme-order-renew-${certName}" = {
        # The managed executor restores WAN on boot. Ordering alone leaves ACME
        # independently runnable once the host already has DNS and egress.
        after = [ "nixos-router-executor.service" ];
        serviceConfig = {
          StandardOutput = "null";
          StandardError = "null";
        };
      };
    })

    (lib.mkIf (cfg.enableACME && cfg.enableProxy) {
      services.nginx = {
        enable = true;
        virtualHosts.${domain} = {
          onlySSL = true;
          listen = [
            (if cfg.publicPort == null then { addr = "127.0.0.1"; port = 18443; ssl = true; }
              else { addr = "0.0.0.0"; port = cfg.publicPort; ssl = true; })
          ];
          sslCertificate = "${cert.directory}/fullchain.pem";
          sslCertificateKey = "${cert.directory}/key.pem";
          extraConfig = ''
            access_log off;
            if ($host != ${domain}) { return 421; }
          '';

          locations = {
            "= /key".extraConfig = ''
              if ($request_method != GET) { return 405; }
              ${forwardHeaders}
              proxy_pass ${upstream}/key;
            '';

            "= /ts2021".extraConfig = ''
              if ($request_method !~ ^(GET|POST)$) { return 405; }
              if ($http_upgrade !~* ^tailscale-control-protocol$) { return 426; }
              ${forwardHeaders}
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
              proxy_buffering off;
              proxy_request_buffering off;
              proxy_read_timeout 3600s;
              proxy_pass ${upstream}/ts2021;
            '';

            "~ ^/register/(?<registration_id>[A-Za-z0-9_-]+)$".extraConfig = ''
              if ($request_method != GET) { return 405; }
              ${forwardHeaders}
              rewrite ^ /register/$registration_id? break;
              proxy_pass ${upstream};
            '';

            "/".return = "404";
          };
        };
      };

      systemd.services.nginx = {
        # The base unit generates a local bootstrap certificate. ACME DNS-01
        # can also run by itself, without starting nginx or Headscale.
        requires = [ baseUnit ];
        after = [ baseUnit ];
        before = [ orderUnit ];
        serviceConfig.SupplementaryGroups = [ certGroup ];
      };
    })
  ];
}
