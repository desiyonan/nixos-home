{ pkgs, ... }:

{
  services.openssh = {
    enable = true;
  };
  programs.ssh = {
    extraConfig =
    ''
    Host *
    ServerAliveInterval 60
    '';
  };
}
