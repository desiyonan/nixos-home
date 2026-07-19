# gw 网关最小化：无桌面、无开发工具链
{ lib, ... }:

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

  fonts.packages = lib.mkForce [ ];
  fonts.fontconfig.enable = lib.mkForce false;
  fonts.fontDir.enable = lib.mkForce false;
}
