{ pkgs, mpkgs, ... }:

{

  environment.systemPackages = with pkgs;[
    cargo
    rustup
  ];
  systemd.extraConfig = 
  ''
  DefaultTimeoutStopSec=20s
  '';

}

