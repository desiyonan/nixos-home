{ pkgs, mpkgs, ... }:

{

  environment.systemPackages = with pkgs;[
    xclip
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

