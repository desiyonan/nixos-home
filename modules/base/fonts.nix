{ config, lib, pkgs, ... }:

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

      # CJK（系统全局 + Steam FHS 默认继承 fonts.packages）
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
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
      allowBitmaps = true;
      cache32Bit = true;
      defaultFonts = {
        monospace = [ "Sarasa Mono SC" ];
        sansSerif = [ "Sarasa UI SC" ];
        serif = [ "Sarasa UI SC" ];
      };
    };

  };
}
