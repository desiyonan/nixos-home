{ config, pkgs, lib, ... }:

{

  # hardware = {
  #   pulseaudio.enable = lib.mkForce false;
  # };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    # socketActivation = false; # start at boot instead.
    audio.enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    jack.enable = true;
    wireplumber = {
      enable= true;
      extraConfig.bluetoothEnhancements = {
        "monitor.bluez.properties" = {
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
            "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
        };
      };
    };
  };

  # systemd.user.services.wireplumber.wantedBy = [ "default.target" ];

  environment.systemPackages =  with pkgs; [
    pavucontrol
  ];

}
