{ ... }:

{
  modules.headscale = {
    serverUrl = "http://s60.dnfn.tech:26616";
    headplaneUrl = "http://127.0.0.1:26616";
    headscalePort = 26616;
    headplanePort = 3000;
    headplaneConfigPath = "/var/lib/headplane/config.yaml";
  };
}
