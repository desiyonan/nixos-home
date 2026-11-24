# Run from the repository root: nix eval --impure --file mesh/hosts/s01/headscale-https/check.nix passed
let
  host = (builtins.getFlake ("git+file:" + toString ../../../..)).nixosConfigurations.s01;
  stage = enable: production: proxy: (host.extendModules {
    modules = [({ lib, ... }: {
      s01.headscaleHttps = {
        enableACME = lib.mkForce enable;
        production = lib.mkForce production;
        enableProxy = lib.mkForce proxy;
        publicPort = lib.mkForce null;
      };
    })];
  }).config;
  baseline = stage false false false;
  staging = stage true false true;
  production = stage true true true;
  acmeOnly = stage true false false;
  public = host.config;
  name = "hs.dnfn.tech";
  stagingName = "headscale-service-staging";
  stagingCert = staging.security.acme.certs.${stagingName};
  productionCert = production.security.acme.certs.headscale-service;
  nginx = staging.systemd.services.nginx;
  orderUnit = "acme-order-renew-${stagingName}.service";
  baseUnit = "acme-${stagingName}.service";
  order = staging.systemd.services."acme-order-renew-${stagingName}";
  vhost = staging.services.nginx.virtualHosts.${name};
in
assert !(baseline.security.acme.certs ? headscale-service-staging);
assert !(baseline.security.acme.certs ? headscale-service);
assert !baseline.services.nginx.enable;
assert !acmeOnly.services.nginx.enable;
assert acmeOnly.security.acme.certs.${stagingName}.reloadServices == [];
assert stagingCert.server == "https://acme-staging-v02.api.letsencrypt.org/directory";
assert productionCert.server == "https://acme-v02.api.letsencrypt.org/directory";
assert stagingCert.directory != productionCert.directory;
assert stagingCert.domain == name && productionCert.domain == name;
assert stagingCert.dnsProvider == "cloudflare" && stagingCert.dnsPropagationCheck;
assert !stagingCert.enableDebugLogs && stagingCert.environmentFile == null;
assert order.serviceConfig.LoadCredential == [
  "CF_DNS_API_TOKEN_FILE:/var/lib/s01-headscale-acme/cloudflare-token"
];
assert vhost.sslCertificate == "${stagingCert.directory}/fullchain.pem";
assert vhost.sslCertificateKey == "${stagingCert.directory}/key.pem";
assert stagingCert.group == "s01-headscale-tls";
assert nginx.serviceConfig.SupplementaryGroups == [ stagingCert.group ];
assert vhost.listen == [{ addr = "127.0.0.1"; port = 18443; ssl = true; proxyProtocol = false; extraParameters = []; }];
assert builtins.elem baseUnit nginx.requires && builtins.elem baseUnit nginx.after;
assert builtins.elem orderUnit nginx.before && !(builtins.elem orderUnit nginx.after);
assert !(builtins.elem "nginx.service" order.requires);
assert !(builtins.elem "nginx.service" order.wants);
assert builtins.elem "nixos-router-executor.service" order.after;
assert !(builtins.elem "nixos-router-executor.service" (order.requires ++ order.wants));
assert builtins.all (unit: !(builtins.elem unit (order.after ++ order.requires ++ order.wants)))
  [ "headscale.service" "k3s.service" "podman-headplane.service" ];
assert stagingCert.reloadServices == [ "nginx.service" ];
assert staging.services.headscale.settings.server_url == baseline.services.headscale.settings.server_url;
assert staging.services.nixos-router.backend.managed.managementAccess ==
  baseline.services.nixos-router.backend.managed.managementAccess;
assert !staging.networking.firewall.enable && !staging.networking.nftables.enable;
assert public.services.nixos-router.backend.managed.wanTCPPorts == [ 24443 ];
assert public.services.headscale.settings.server_url == "https://hs.dnfn.tech:24443";
assert public.services.headscale.address == baseline.services.headscale.address;
assert public.services.headscale.port == baseline.services.headscale.port;
assert public.services.headscale.address == "127.0.0.1";
assert public.services.headscale.port == 28080;
assert public.services.nginx.virtualHosts.${name}.listen == [
  { addr = "0.0.0.0"; port = 24443; ssl = true; proxyProtocol = false; extraParameters = []; }
];
{
  passed = true;
  defaultSystem = baseline.system.build.toplevel;
  stagingSystem = staging.system.build.toplevel;
  productionSystem = production.system.build.toplevel;
  acmeOnlySystem = acmeOnly.system.build.toplevel;
}
