{ mt7927, nixos-router, ... }:

{
  imports = [
    mt7927.nixosModules.default
    nixos-router.nixosModules.default
    ./configuration.nix
    ./modules.nix
    ./memory.nix
    ./router-managed.nix
    ./zerotier-controller.nix
    ./headscale.nix
    ./headscale-https
    ./headplane.nix
    ./cloudflare-ddns
  ];

  s01.cloudflareDDNS = {
    record = "s01.dnfn.tech";
    recordType = "A";
    interface = "nr-ppp0";
    intervalMinutes = 5;
  };

  s01.headscaleHttps = {
    enableACME = true;
    production = true;
    enableProxy = true;
    publicPort = 24443;
  };

  services.nixos-router.backend = {
    enable = true;
    address = ":8080";
    applyReload = false;
    applyTrafficControl = false;
    privilegedApply = false;
    consumeGenerated = false;
    openFirewall = false;
    allowReboot = false;
  };

}
