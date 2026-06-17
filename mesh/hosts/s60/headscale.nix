{ ... }:

{
  modules.headscale = {
    openFirewall = false;
    serverUrl = "https://s60.dnfn.tech";
    headplaneUrl = "http://127.0.0.1:26616";
    headscalePort = 26616;
    headplanePort = 3000;
    headplaneConfigPath = "/var/lib/headplane/config.yaml";
  };

  services.nginx = {
    enable = true;
    group = "x3-ui";
    recommendedProxySettings = true;
    virtualHosts."s60.dnfn.tech" = {
      forceSSL = true;
      useACMEHost = "s60-dnfn-tech";
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:26616";
          extraConfig = ''
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
            proxy_buffering off;
          '';
        };
        "/admin/" = {
          proxyPass = "http://127.0.0.1:3000/admin/";
        };
      };
    };
  };

  systemd.services.nginx = {
    after = [ "acme-s60-dnfn-tech.service" ];
    requires = [ "acme-s60-dnfn-tech.service" ];
  };
}
