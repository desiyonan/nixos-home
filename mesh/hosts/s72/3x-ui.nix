# 3x-ui：x-ui.db 由 secret-hub bind 注入；面板配置仅来自数据库
{ lib, ... }:

let
  domain = "s72.dnfn.tech";
  certName = "s72-dnfn-tech";
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

  # 443：VLESS Reality（16881 在运营商侧 QoS/超时，压测 443 可用）
  # 31944/2096：面板与订阅；80：ACME HTTP-01
  networking.firewall.allowedTCPPorts = lib.mkAfter [
    80
    443
    2096
    31944
  ];

  modules.x3-ui.enable = true;

  systemd.services.x3-ui = {
    after = lib.mkAfter [ "acme-${certName}.service" ];
    requires = [ "acme-${certName}.service" ];
  };
}
