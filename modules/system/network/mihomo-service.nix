# pkgs.mihomo + services.mihomo；配置来自 sops（LoadCredential）
{ config, lib, pkgs, ... }:

let
  cfg = config.modules.network;
  proxyCfg = cfg.proxy;
  mihomoCfg = proxyCfg.mihomo;
  # secret-hub 默认落盘路径；与 modules.network.proxy.mihomo.configFile 对齐
  mihomoSecretName = "programs/mihomo/config.yaml";
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

    # 配置更新后重启；secret-hub 无 activationScripts.setupSecrets（无 sops-nix.service）
    sops.secrets.${mihomoSecretName}.restartUnits = [ "mihomo.service" ];

    systemd.services.mihomo = {
      after = lib.mkAfter [ "systemd-tmpfiles-setup.service" ];
      # LoadCredential 在 ExecStartPre 之前执行；缺文件会报 243/CREDENTIALS。
      # 解密失败时跳过启动（不拖垮 nixos-rebuild），便于先修 sops/GPG。
      unitConfig.ConditionPathExists = [ mihomoCfg.configFile ];
    };
  };
}
