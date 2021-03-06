{ config, pkgs, ... }:

{
  imports = [
    ./zerotierone.nix
  ];

  services.resolved = {
    enable = true;
    dnssec = "false";
    domains = [
      "dnfn.tech"
    ];
    fallbackDns = [
      "223.5.5.5"
      "223.6.6.6"
      "8.8.8.8"
      "2400:3200::1"
      "2400:3200:baba::1"
      # "192.168.123.251"
    ];
    # extraConfig =
    # ''
    #   DNS=192.168.123.251 192.168.123.1
    # '';
  };

}
