{ config, pkgs, ... }:

{
  i18n = {
    inputMethod = {
      enabled = "fcitx5";
      # fcitx.engines = with pkgs.fcitx-engines; [ m17n ];
      fcitx5.addons = with pkgs; [ fcitx5-m17n fcitx5-chinese-addons ];
    };
  };

  environment = {
    variables = {
      GTK_IM_MODULE = "fcitx";
      INPUT_METHOD="fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "\@im=fcitx";
    };
    sessionVariables = {
      GTK_IM_MODULE = "fcitx";
      INPUT_METHOD="fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "\@im=fcitx";
    };
  };

}
