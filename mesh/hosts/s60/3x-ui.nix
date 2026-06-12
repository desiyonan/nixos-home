# 3x-ui：x-ui.db 由 secret-hub bind 注入；面板配置仅来自数据库
{ lib, ... }:

let
  domain = "s60.dnfn.tech";
  certName = "s60-dnfn-tech";
in
{
  security.acme = {
    acceptTerms = true;
    defaults.email = "1310332521@qq.com";
    certs.${certName} = {
      inherit domain;
      group = "x3-ui";
      listenHTTP = ":80";
      reloadServices = [ "x3-ui.service" ];
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
