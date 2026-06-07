{ ... }:

let
  wanInterface = "enp3s0";
  lanBridge = "br0";
  lanInterfaces = [
    "enp4s0"
    "enp5s0"
    "enp6s0"
  ];
  lanAddress = "192.168.124.1";
  lanPrefixLength = 24;
in
{
  networking = {
    useDHCP = false;

    interfaces.${wanInterface}.useDHCP = true;
    interfaces.${lanBridge} = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = lanAddress;
          prefixLength = lanPrefixLength;
        }
      ];
    };

    bridges.${lanBridge}.interfaces = lanInterfaces;

    nat = {
      enable = true;
      externalInterface = wanInterface;
      internalInterfaces = [ lanBridge ];
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      interfaces.${lanBridge} = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [
          53
          67
        ];
      };
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      interface = lanBridge;
      bind-interfaces = true;
      domain-needed = true;
      bogus-priv = true;
      dhcp-range = [ "192.168.124.100,192.168.124.250,24h" ];
      dhcp-option = [
        "option:router,${lanAddress}"
        "option:dns-server,${lanAddress}"
      ];
      server = [
        "223.5.5.5"
        "223.6.6.6"
        "1.1.1.1"
      ];
    };
  };
}
