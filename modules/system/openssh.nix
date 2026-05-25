{ config, lib, pkgs, ... }:

let
  cfg = config.modules.openssh;
in
{
  options.modules.openssh = {
    enable = lib.mkEnableOption "OpenSSH server and client defaults";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      extraConfig = ''
        AllowTcpForwarding=yes
      '';
    };
    programs.ssh = {
      extraConfig = ''
        Host *
        ServerAliveInterval 60
      '';
    };
  };
}
