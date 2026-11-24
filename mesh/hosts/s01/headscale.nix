{ config, ... }:

let
  https = config.s01.headscaleHttps;
in

{
  # Headscale's raw HTTP listener is used only by local nginx and Headplane.
  services.headscale = {
    enable = true;
    address = "127.0.0.1";
    port = 28080;
    settings = {
      server_url = if https.publicPort == null
        then "http://${config.services.headscale.address}:${toString config.services.headscale.port}"
        else "https://${https.domain}:${toString https.publicPort}";
      prefixes = {
        v4 = "100.96.0.0/16";
        v6 = "fd7a:115c:a1e0:100::/64";
      };
      dns = {
        magic_dns = false;
        override_local_dns = false;
      };
      derp.server.enabled = false;
    };
  };

  systemd.services.headscale = {
    after = [ "zerotierone.service" ];
    wants = [ "zerotierone.service" ];
    # The management address may appear after zerotier-one has started.
    unitConfig.StartLimitIntervalSec = 0;
  };
}
