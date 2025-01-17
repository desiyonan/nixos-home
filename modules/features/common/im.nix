{ config, pkgs, lib, ... }:

{
  i18n = {
    inputMethod = {
      enable = true;
      type = "fcitx5" ;
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-chinese-addons
          fcitx5-configtool
          fcitx5-m17n
        ];
      };
    };
  };

  environment = {
    variables = {
      INPUT_METHOD= "fcitx";
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = ''@im=fcitx'';
    };
    sessionVariables = {
      # ISSUE: fcitx5 don't work on wayland (https://github.com/NixOS/nixpkgs/issues/129442)
      NIX_PROFILES = "${lib.concatStringsSep " " (lib.reverseList config.environment.profiles)}";
      INPUT_METHOD= "fcitx";
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE =  "fcitx";
      XMODIFIERS =  ''@im=fcitx'';
    };
  };

}
