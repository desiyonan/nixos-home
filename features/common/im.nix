{ config, pkgs, lib, mpkgs, ... }:

{
  i18n = {
    inputMethod = {
      enabled = "fcitx5" ;
      # enabled = "ibus" ;
      ibus.panel = "${pkgs.plasma5Packages.plasma-desktop}/lib/libexec/kimpanel-ibus-panel";
      ibus.engines = with pkgs.ibus-engines;
      [
        table-chinese
        libpinyin
        uniemoji
      ];
      fcitx5.addons = with pkgs; [
        fcitx5-chinese-addons
        fcitx5-configtool
        fcitx5-m17n
        fcitx5-rime
        libsForQt5.fcitx5-qt
      ];
    };
  };

  # environment = {
  #    systemPackages = with pkgs; [
  #     #  fcitx5-configtool
  #     #  fcitx5-m17n
  #     # libsForQt5.fcitx5-qt
  #   ];
  #   variables = {
  #     INPUT_METHOD= lib.mkForce "fcitx";
  #     GTK_IM_MODULE = lib.mkForce "fcitx";
  #     QT_IM_MODULE = lib.mkForce "fcitx";
  #     XMODIFIERS = lib.mkForce ''@im=fcitx'';
  #   };
  #   sessionVariables = {
  #     INPUT_METHOD= lib.mkForce "fcitx";
  #     GTK_IM_MODULE = lib.mkForce "fcitx";
  #     XMODIFIERS = lib.mkForce ''@im=fcitx'';
  #     QT_IM_MODULE = lib.mkForce "fcitx";
  #   };
  # };

}
