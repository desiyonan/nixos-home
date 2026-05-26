# pkgs.mihomo + services.mihomo；配置来自 sops（LoadCredential）
{ config, lib, pkgs, ... }:

let
  cfg = config.modules.network;
  proxyCfg = cfg.proxy;
  mihomoCfg = proxyCfg.mihomo;
in
{
  config = lib.mkIf (cfg.enable && proxyCfg.enable) {
    services.mihomo = {
      enable = true;
      package = pkgs.mihomo;
      configFile = mihomoCfg.configFile;
      webui = if mihomoCfg.webui.enable then pkgs.metacubexd else null;
      tunMode = mihomoCfg.tunMode;
    };

    systemd.services.mihomo = {
      after = lib.mkAfter [
        "sops-nix.service"
        "systemd-tmpfiles-setup.service"
      ];
      wants = [ "sops-nix.service" ];
    };
  };
}
