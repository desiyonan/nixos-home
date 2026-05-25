{ config, lib, pkgs, ... }:

let
  cfg = config.modules.im;
in
{
  options.modules.im = {
    enable = lib.mkEnableOption "Fcitx5 input method (Chinese/Japanese, Wayland-friendly)";
  };

  config = lib.mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        ignoreUserConfig = true;
        addons = with pkgs; [
          qt6Packages.fcitx5-chinese-addons
          qt6Packages.fcitx5-configtool
          qt6Packages.fcitx5-qt
          fcitx5-mozc
          fcitx5-gtk
          fcitx5-m17n
          fcitx5-nord
        ];
      };
    };

    # waylandFrontend=true 时，nixpkgs 的 fcitx5 模块会设置 XMODIFIERS、QT_PLUGIN_PATH，
    # 并刻意不设 GTK_IM_MODULE / QT_IM_MODULE，让客户端走 Wayland text-input（见 nixpkgs#270432）。
    # 若在此处再强制 *_IM_MODULE，Chromium/Electron 在无 XWayland 时常见无法输入中文。
    environment.sessionVariables = {
      NIX_PROFILES = "${lib.concatStringsSep " " (lib.reverseList config.environment.profiles)}";
      NIXOS_OZONE_WL = "1";
    };
  };
}
