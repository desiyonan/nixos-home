# 3x-ui 面板：settings.yaml 由 secret-hub 注入
{ ... }:

{
  modules.x3-ui = {
    enable = true;
    port = 31944;
    settingsFile = "/run/secrets/hosts/srimsiuh-71/var/lib/3x-ui/settings.yaml";
  };
}
