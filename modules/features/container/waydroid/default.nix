{ pkgs, ... }:
{


  environment.systemPackages =  with pkgs; [
    wl-clipboard
  ];

  virtualisation = {
    waydroid.enable = true;
    lxd.enable = true;
  };
}
