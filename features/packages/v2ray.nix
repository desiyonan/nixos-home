{ config, pkgs, ... }:

{

  # networking = {
  #   proxy  = {
  #     allProxy = "socks5://localhost:1080";
  #     noProxy  = "127.0.0.1,localhost,desiyonan.tech";
  #   };
  # };

  environment.systemPackages = with pkgs; [
    qv2ray
  ];

  services = {
    v2ray = {
      enable = true;
      configFile = "/opt/env/v2ray/config.json";
    };
  };

}
