{ config, pkgs, ... }:

{
  time.timeZone = "Asia/Shanghai";

  location = {
    latitude = 29.471919;
    longitude = 101.536115;
  };

  i18n = {
    supportedLocales = ["all"];
    defaultLocale = "zh_CN.UTF-8";

    inputMethod = {
      enabled = "fcitx";
      fcitx.engines = with pkgs.fcitx-engines; [ m17n ];
    };
  };

  console.keyMap = "us";
}
