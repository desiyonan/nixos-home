{ pkgs, ... }:

{
  services.openssh = {
    enable = true;
    extraConfig = ''
      AllowTcpForwarding=yes
    '';
  };
  programs.ssh = {
    extraConfig =
    ''
    Host *
    ServerAliveInterval 60
    '';
  };
}
