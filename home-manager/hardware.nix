{ config, pkgs, ... }:

{

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  # Try to fix default shitty sound experience on Carbon
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
  };
}
