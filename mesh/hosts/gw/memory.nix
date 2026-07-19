# gw 网关最小化：无桌面、无开发工具链
{ lib, pkgs, ... }:

{
  services.journald.extraConfig = ''
    SystemMaxUse=50M
    RuntimeMaxUse=30M
    MaxRetentionSec=7day
  '';

  networking.wireless.enable = lib.mkForce false;
  networking.modemmanager.enable = false;
  security.polkit.enable = false;

  # home-manager.users = lib.mkForce { };

  users.users.dnf.extraGroups = lib.mkForce [
    "users"
    "wheel"
  ];

  # 仍去掉桌面字体包，但保留 kmscon 中文 TTY 所需最小集
  fonts.packages = lib.mkForce (
    with pkgs;
    [
      sarasa-gothic
      noto-fonts-cjk-sans
      wqy_microhei
    ]
  );
  fonts.fontconfig.enable = true;
  fonts.fontDir.enable = lib.mkForce false;
}
