{ config, pkgs, ... }:

{
  imports = [
    ./zerotierone.nix
  ];

  networking.enableIPv6 = false;
  networking.proxy = {
    allProxy = "http://localhost:7890";
    httpProxy = "http://localhost:7890";
    httpsProxy = "http://localhost:7890";
  };
  services.resolved = {
    enable = true;
    dnssec = "false";
    domains = [
      "nodes.dnfn.tech"
    ];
    fallbackDns = [
      "223.5.5.5"
      "223.6.6.6"
      "8.8.8.8"
      "1.1.1.1"
      # "2400:3200::1"
      # "2400:3200:baba::1"
      # "192.168.123.251"
    ];
    # extraConfig =
    # ''
    #   DNS=192.168.123.251 192.168.123.1
    # '';
  };
  services.create_ap = {
    enable = true;
    settings = {
      INTERNET_IFACE = "eth0";
      WIFI_IFACE = "wlp0s20f3";
      SSID = "DnF-WF";
      PASSPHRASE = "DnFn_WF159753";
      FREQ_BAND="2.4";
    };
  };
}
