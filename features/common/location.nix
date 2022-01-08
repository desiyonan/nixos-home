{ config, pkgs, ... }:

{
  time.timeZone = "Asia/Shanghai";

  location = {
    latitude = 29.471919;
    longitude = 101.536115;
  };

  i18n = {
    supportedLocales = ["all"];
    defaultLocale = "zh_CN.utf8";

    inputMethod = {
      enabled = "fcitx5";
      # fcitx.engines = with pkgs.fcitx-engines; [ m17n ];
      fcitx5.addons = with pkgs; [ fcitx5-m17n ];
    };
  };

  console.keyMap = "us";
}
