{ pkgs,  ... }:

{

  environment.systemPackages = with pkgs;[
    chromium
    firefox
    google-chrome
    # vivaldi
    # vivaldi-ffmpeg-codecs

  ];

}
