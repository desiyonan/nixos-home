{ config, pkgs, ... }:

{
  fonts = {
    # enableGhostscriptFonts = true;
    fontDir.enable = true;

    packages = with pkgs; [
      inconsolata
      # inconsolata-nerdfont
      nerd-fonts.inconsolata
      jetbrains-mono
      dejavu_fonts
      dejavu_fontsEnv
      noto-fonts
      noto-fonts-cjk-sans
      # noto-fonts-emoji
      noto-fonts-color-emoji
      sarasa-gothic
      wqy_microhei
      wqy_zenhei

      corefonts
      # vistafonts
      # vistafonts-cht
      # vistafonts-chs
      vista-fonts
      vista-fonts-cht
      vista-fonts-chs
    ];

    fontconfig = {
      enable = true;
      allowType1 = true;
      allowBitmaps= true;
      defaultFonts = {
        monospace = [ "Sarasa Mono SC" ];
        sansSerif = [ "Sarasa UI SC" ];
        serif = [ "Sarasa UI SC" ];
      };
    };

  };
}
