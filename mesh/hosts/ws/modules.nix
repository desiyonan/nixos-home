# 按 host 启用 modules/ 下可复用模块（options.modules.<name>.enable）
# Development tools are on by default (options.modules.develop); e.g. modules.develop.rust.enable = false;
{ config, lib, pkgs, ... }:

{
  modules.network.enable = true;
  modules.network.enableIPv6 = false;
  modules.network.proxy.enable = true;

  modules.graphical.enable = true;
  modules.graphical.nvidia.enable = true;
  modules.secrets.enable = true;
  secret-hub.extraSecrets = [
    "programs"
    "account"
  ];
  modules.vlan.enable = true;

  modules.devops.enable = true;

  modules.game.enable = true;
}
