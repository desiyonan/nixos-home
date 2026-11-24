{ config, pkgs, ... }:

let
  headplaneConfig = pkgs.writeText "s01-headplane.yaml" ''
    server:
      host: "127.0.0.1"
      port: 3000
      base_url: "http://localhost:3000"
      cookie_secret_path: "/var/lib/headplane/cookie-secret"
      cookie_secure: false
      data_path: "/var/lib/headplane/data"
    headscale:
      url: "http://${config.services.headscale.address}:${toString config.services.headscale.port}"
      config_path: "/etc/headscale/config.yaml"
    integration:
      agent:
        enabled: false
      docker:
        enabled: false
      kubernetes:
        enabled: false
        pod_name: "headscale"
      proc:
        enabled: false
  '';
in
{
  systemd.services.headplane-secrets = {
    description = "Prepare persistent Headplane session and login credentials";
    requires = [ "headscale.service" ];
    after = [ "headscale.service" ];
    before = [ "podman-headplane.service" ];
    path = [ pkgs.coreutils pkgs.openssl config.services.headscale.package ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StateDirectory = "headplane";
      StateDirectoryMode = "0700";
      UMask = "0077";
    };
    script = ''
      set -eu
      mkdir -p /var/lib/headplane/data
      if ! test -s /var/lib/headplane/cookie-secret; then
        openssl rand -hex 16 | tr -d '\n' > /var/lib/headplane/cookie-secret.tmp
        mv /var/lib/headplane/cookie-secret.tmp /var/lib/headplane/cookie-secret
      fi
      if ! test -s /var/lib/headplane/login-api-key; then
        for attempt in $(seq 1 30); do
          if headscale apikeys list >/dev/null 2>&1; then break; fi
          sleep 1
        done
        headscale apikeys create --expiration 365d > /var/lib/headplane/login-api-key.tmp
        test -s /var/lib/headplane/login-api-key.tmp
        mv /var/lib/headplane/login-api-key.tmp /var/lib/headplane/login-api-key
      fi
    '';
  };

  virtualisation.oci-containers.containers.headplane = {
    image = "ghcr.io/tale/headplane@sha256:b053a0a6699d0a67be3f0d9bae8e7dbe35ed67ae8448412adcbad7ea49866faa";
    volumes = [
      "${headplaneConfig}:/etc/headplane/config.yaml:ro"
      "${config.services.headscale.configFile}:/etc/headscale/config.yaml:ro"
      "/var/lib/headplane:/var/lib/headplane"
    ];
    extraOptions = [ "--network=host" ];
  };
  systemd.services.podman-headplane = {
    requires = [ "headplane-secrets.service" ];
    after = [ "headplane-secrets.service" "headscale.service" ];
  };
}
