{ pkgs, mpkgs, ... }:

{

  environment.systemPackages = with pkgs;[
    iw
    cargo
    gparted
    rustup
  ];
  systemd.extraConfig = 
  ''
  DefaultTimeoutStopSec=10s
  '';

}

