{ pkgs, mpkgs, ... }:

{

  environment.systemPackages = with pkgs;[
    cargo
    gparted
    rustup
  ];
  systemd.extraConfig = 
  ''
  DefaultTimeoutStopSec=20s
  '';

}

