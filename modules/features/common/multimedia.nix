{ config, pkgs, ... }:

{
  sound.enable = false;

  # hardware = {
  #   pulseaudio.enable = true;
  # };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    # wireplumber.enable= true;
    # audio.enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    # jack.enable = true;
  };

}
