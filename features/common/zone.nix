{ config, pkgs, ... }:

{
  time.timeZone = "Asia/Shanghai";

  location = {
    latitude = 29.471919;
    longitude = 101.536115;
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
  i18n = {
    supportedLocales = ["all"];
    defaultLocale = "zh_CN.UTF-8";
  };

}
