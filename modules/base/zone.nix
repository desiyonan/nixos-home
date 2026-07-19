{ config, pkgs, ... }:

{
  time.timeZone = "Asia/Shanghai";

  location = {
    latitude = 29.471919;
    longitude = 101.536115;
  };

  # 登录后的 VT 由 services.kmscon 接管（见 kmscon.nix）；此处仅影响早期内核控制台
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
  i18n = {
    supportedLocales = ["all"];
    defaultLocale = "zh_CN.UTF-8";
  };

}
