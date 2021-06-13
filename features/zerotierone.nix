{ pkgs, ... }:

{
  services = {
    zerotierone = {
      enable = true;
      joinNetworks = ["af78bf94369e9f0b"];
    };
  };
}
