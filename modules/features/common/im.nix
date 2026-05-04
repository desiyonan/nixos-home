{ config, pkgs, lib, ... }:

{
  i18n = {
    inputMethod = {
      enable = true;
      type = "fcitx5" ;
      fcitx5 = {
        waylandFrontend = true;
        ignoreUserConfig = true;
        addons = with pkgs; [
          # fcitx5-chinese-addons
          # fcitx5-configtool
          qt6Packages.fcitx5-chinese-addons
          qt6Packages.fcitx5-configtool
          # Plasma 6 / Qt6 与纯 Wayland 下建议保留；勿再手动设 QT_IM_MODULE（会与 text-input 冲突）
          qt6Packages.fcitx5-qt

          fcitx5-mozc
          fcitx5-gtk
          fcitx5-m17n
          fcitx5-nord            # a color theme
        ];
      };
    };
  };

  # waylandFrontend=true 时，nixpkgs 的 fcitx5 模块会设置 XMODIFIERS、QT_PLUGIN_PATH，
  # 并刻意不设 GTK_IM_MODULE / QT_IM_MODULE，让客户端走 Wayland text-input（见 nixpkgs#270432）。
  # 若在此处再强制 *_IM_MODULE，Chromium/Electron 在无 XWayland 时常见无法输入中文。
  environment.sessionVariables = {
    # https://github.com/NixOS/nixpkgs/issues/129442
    NIX_PROFILES = "${lib.concatStringsSep " " (lib.reverseList config.environment.profiles)}";
    # nixpkgs 的 cursor 包装：仅当 NIXOS_OZONE_WL 与 WAYLAND_DISPLAY 均存在时才注入
    # --enable-wayland-ime / --wayland-text-input-version=3；缺省时纯 Wayland 下 fcitx5 常无法唤起
    NIXOS_OZONE_WL = "1";
  };

}
