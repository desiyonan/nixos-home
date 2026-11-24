{ pkgs, ... }:

{
  # Retain the existing identity and memberships; enable the controller in the same daemon.
  services.zerotierone.package = pkgs.zerotierone.override { enableUnfree = true; };
  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  systemd.services.ztnet-secrets = {
    description = "Prepare persistent ZTNET credentials";
    wantedBy = [ "multi-user.target" ];
    before = [ "podman-ztnet.service" "podman-ztnet-postgres.service" ];
    path = [ pkgs.coreutils pkgs.openssl ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StateDirectory = "ztnet";
      StateDirectoryMode = "0700";
      UMask = "0077";
    };
    script = ''
      set -eu
      if ! test -s /var/lib/ztnet/database.env; then
        password=$(openssl rand -hex 32)
        printf 'POSTGRES_USER=ztnet\nPOSTGRES_DB=ztnet\nPOSTGRES_PASSWORD=%s\n' "$password" > /var/lib/ztnet/database.env.tmp
        mv /var/lib/ztnet/database.env.tmp /var/lib/ztnet/database.env
      fi
      if ! test -s /var/lib/ztnet/session.env; then
        printf 'NEXTAUTH_SECRET=%s\n' "$(openssl rand -hex 32)" > /var/lib/ztnet/session.env.tmp
        mv /var/lib/ztnet/session.env.tmp /var/lib/ztnet/session.env
      fi
      mkdir -p /var/lib/ztnet/postgres
    '';
  };

  virtualisation.oci-containers.containers = {
    ztnet-postgres = {
      image = "docker.io/library/postgres@sha256:23799e521dee9265a8b388ecf3bc0f1eaa34b95be67f5a76af4f8f6adb44c720";
      environmentFiles = [ "/var/lib/ztnet/database.env" ];
      volumes = [ "/var/lib/ztnet/postgres:/var/lib/postgresql/data" ];
      extraOptions = [ "--network=host" ];
      cmd = [ "postgres" "-c" "listen_addresses=127.0.0.1" "-p" "5433" ];
    };
    ztnet = {
      image = "docker.io/sinamics/ztnet@sha256:6588073237827a7a5068d4867b56b520c30bf8a6f11199bf9d85c947e63f5bc5";
      dependsOn = [ "ztnet-postgres" ];
      environmentFiles = [ "/var/lib/ztnet/database.env" "/var/lib/ztnet/session.env" ];
      environment = {
        POSTGRES_HOST = "127.0.0.1";
        POSTGRES_PORT = "5433";
        ZT_ADDR = "http://127.0.0.1:9993";
        ZT_SECRET_FILE = "/run/zt-authtoken.secret";
        HOSTNAME = "127.0.0.1";
        PORT = "3100";
        NEXTAUTH_URL = "http://localhost:3100";
        NEXTAUTH_URL_INTERNAL = "http://127.0.0.1:3100";
      };
      volumes = [ "/var/lib/zerotier-one/authtoken.secret:/run/zt-authtoken.secret:ro" ];
      extraOptions = [ "--network=host" ];
    };
  };

  systemd.services.podman-ztnet-postgres = {
    requires = [ "ztnet-secrets.service" ];
    after = [ "ztnet-secrets.service" ];
  };
  systemd.services.podman-ztnet = {
    requires = [ "ztnet-secrets.service" "zerotierone.service" ];
    after = [ "ztnet-secrets.service" "zerotierone.service" ];
  };
}
