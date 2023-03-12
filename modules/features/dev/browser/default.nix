{ pkgs, mpkgs, ... }:

{

  environment.systemPackages = with pkgs;[
    firefox
    google-chrome
    # vivaldi
    # vivaldi-ffmpeg-codecs

  ];

}
