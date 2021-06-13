{ config, pkgs, ... }:

{
  time.timeZone = "Asia/Shanghai";

  location = {
    # Quebec City
    latitude = 29.471919;
    longitude = 101.536115;
  };
}
