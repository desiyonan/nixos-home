{ pkgs,  ... }:

{

  environment.systemPackages = with pkgs;[
    xclip
    iw
    # cargo
    gparted
    rustup
  ];
  systemd.settings.Manager = {
    DefaultTimeoutStopSec="10s";
  };
  services.flatpak.enable = true;

}

