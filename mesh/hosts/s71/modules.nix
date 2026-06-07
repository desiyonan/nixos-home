# s71 host 模块开关（网络/SSH 见 configuration.nix）
# VPS：DHCP 上网、SSH、可选组网；无桌面
{ ... }:

{
  modules.network.enable = true;
  modules.network.enableIPv6 = true;
  modules.network.networkManager.enable = true;
  modules.network.resolved.enable = true;
  modules.network.proxy.enable = false;

  modules.openssh.enable = true;
  modules.vlan.enable = false;
  modules.secrets.enable = true;

  modules.graphical.enable = false;
  modules.devops.enable = false;
  modules.develop.enable = false;
}
