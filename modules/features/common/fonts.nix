{ config, pkgs, ... }:

{
  fonts = {
    # enableGhostscriptFonts = true;
    # fontDir.enable = true;

    packages = with pkgs; [
      inconsolata
      inconsolata-nerdfont
      jetbrains-mono
      dejavu_fonts
      dejavu_fontsEnv
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      sarasa-gothic
      wqy_microhei
      wqy_zenhei
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "Sarasa Mono SC" ];
        sansSerif = [ "Sarasa UI SC" ];
        serif = [ "Sarasa UI SC" ];
      };
    };

  };
}
