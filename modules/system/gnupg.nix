{ config, lib, pkgs, ... }:

let
  cfg = config.modules.gnupg;
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
        # qt/gnome3 用于 Plasma 等图形会话，curses/tty 用于 SSH 与纯终端
        pinentryPackage = pkgs.pinentry-all;
        settings = {
          default-cache-ttl = 2 * 60 * 60;
        };
      };
    };
    # GPG_TTY 由 programs.gnupg 模块写入 interactiveShellInit，供终端下弹出 passphrase
    environment.systemPackages = with pkgs; [
      pinentry-all
    ];
  };
}
