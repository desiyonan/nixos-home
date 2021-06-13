{ config, pkgs, ... }:

{

  services.resolved.enable = true ;
  services.resolved.fallbackDns = [
      "223.5.5.5"
      "223.6.6.6"
      "8.8.8.8"
      "2400:3200::1"
      "2400:3200:baba::1"
  ];

}
