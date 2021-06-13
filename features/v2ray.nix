{ config, pkgs, ... }:

{

  services = {
    v2ray = {
      enable = true;
      configFile = "/opt/env/v2ray/config.json";
    };
  };

}
