{ config, pkgs, lib, ... }:

{
  i18n = {
    inputMethod = {
      enabled = "fcitx5" ;
      fcitx5.addons = with pkgs; [
        fcitx5-chinese-addons
        fcitx5-configtool
        fcitx5-m17n
        fcitx5-rime
        libsForQt5.fcitx5-qt
      ];
    };
  };

  environment = {
     systemPackages = with pkgs; [
      #  fcitx5-configtool
      #  fcitx5-m17n
      # libsForQt5.fcitx5-qt
    ];
    variables = {
      INPUT_METHOD= lib.mkForce "fcitx";
      GTK_IM_MODULE = lib.mkForce "fcitx";
      QT_IM_MODULE = lib.mkForce "fcitx";
      XMODIFIERS = lib.mkForce ''@im=fcitx'';
    };
    sessionVariables = {
      INPUT_METHOD= lib.mkForce "fcitx5";
      GTK_IM_MODULE = lib.mkForce "fcitx5";
      XMODIFIERS = lib.mkForce ''@im=fcitx5'';
      QT_IM_MODULE = lib.mkForce "fcitx";
    };
  };

}
