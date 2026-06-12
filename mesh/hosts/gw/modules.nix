# 按 host 启用 modules/ 下可复用模块（options.modules.<name>.enable）
{ ... }:

{
  modules.network.enable = true;
  modules.network.enableIPv6 = true;
  modules.network.networkManager.enable = false;
  modules.network.resolved.enable = false;
  modules.network.proxy.enable = false;

  modules.openssh.enable = true;
  modules.vlan.enable = true;
  secret-hub.enable = false;

  modules.graphical.enable = false;
  modules.devops.enable = false;
}
