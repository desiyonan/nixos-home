# 按 host 启用 modules/ 下可复用模块（options.modules.<name>.enable）
# Development tools are on by default (options.modules.develop); e.g. modules.develop.rust.enable = false;
{ config, lib, pkgs, ... }:

{
  modules.network.enable = true;
  modules.network.proxy.enable = true;
  modules.gui.enable = true;
  modules.gui.nvidia.enable = true;
  modules.secrets.enable = true;
  modules.vlan.enable = true;

  modules.devops.enable = true;
}
