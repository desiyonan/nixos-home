{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.git
    pkgs.gh
  ];

  programs.git = {
    enable = true;
  };
}
