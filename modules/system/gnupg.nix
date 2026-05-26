{ config, lib, pkgs, ... }:

let
  cfg = config.modules.gnupg;
  pinentryAuto = pkgs.writeShellScriptBin "pinentry" ''
    set -euo pipefail

    if [[ -n "''${DISPLAY-}" || -n "''${WAYLAND_DISPLAY-}" ]]; then
      exec ${pkgs.pinentry-qt}/bin/pinentry-qt "''$@"
    fi

    exec ${pkgs.pinentry-curses}/bin/pinentry-curses "''$@"
  '';
in
{
  options.modules.gnupg = {
    enable = lib.mkEnableOption "GnuPG agent with SSH and browser socket support";
  };

  config = lib.mkIf cfg.enable {
    modules.openssh.enable = lib.mkDefault true;

    programs.gnupg = {
      agent = {
        enable = true;
        enableExtraSocket = true;
        enableSSHSupport = true;
        enableBrowserSocket = true;
        # 图形会话优先使用 qt；无图形/SSH 自动回落到 curses
        pinentryPackage = pinentryAuto;
        settings = {
          default-cache-ttl = 2 * 60 * 60;
        };
      };
    };
    # GPG_TTY 由 programs.gnupg 模块写入 interactiveShellInit，供终端下弹出 passphrase
    environment.systemPackages = with pkgs; [
      pinentry-qt
      pinentry-curses
    ];
  };
}
