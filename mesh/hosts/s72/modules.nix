# s72 host 模块开关（网络/SSH 见 configuration.nix）
{ ... }:

{
  modules.network.enable = true;
  modules.network.enableIPv6 = true;
  modules.network.networkManager.enable = false;
  modules.network.resolved.enable = true;
  modules.network.proxy.enable = false;

  modules.openssh.enable = true;
  modules.vlan.enable = false;

  modules.graphical.enable = false;
  modules.devops.enable = false;
  modules.develop.enable = false;
}
