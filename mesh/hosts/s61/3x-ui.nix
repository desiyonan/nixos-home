# 3x-ui：x-ui.db 由 secret-hub bind 注入；面板配置仅来自数据库
{ lib, ... }:

let
  domain = "s61.dnfn.tech";
  certName = "s61-dnfn-tech";
in
{
  security.acme = {
    acceptTerms = true;
    defaults.email = "1310332521@qq.com";
    certs.${certName} = {
      inherit domain;
      # 过渡期：ws/手机 Tailscale ControlURL 仍为 s60，证书需同时覆盖
      extraDomainNames = [ "s60.dnfn.tech" ];
      group = "x3-ui";
      dnsProvider = "cloudflare";
      environmentFile = "/var/lib/acme/cloudflare-dns-dnfn-tech";
      reloadServices = [
        "x3-ui.service"
        "nginx.service"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = lib.mkAfter [
    80
    2096
    31944
    16881
  ];

  modules.x3-ui.enable = true;

  systemd.services.x3-ui = {
    after = lib.mkAfter [ "acme-${certName}.service" ];
    requires = [ "acme-${certName}.service" ];
  };
}
