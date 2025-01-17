{ config, pkgs, lib, ... }:

{

  # hardware = {
  #   pulseaudio.enable = lib.mkForce false;
  # };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    # socketActivation = false; # start at boot instead.
    wireplumber.enable= true;
    audio.enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    jack.enable = true;
  };

  # systemd.user.services.wireplumber.wantedBy = [ "default.target" ];

  environment.systemPackages =  with pkgs; [
    pavucontrol
  ];

}
