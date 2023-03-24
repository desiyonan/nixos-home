{ pkgs, mpkgs, ... }:

{
  environment.systemPackages = [
    pkgs.git
    pkgs.gh
    pkgs.subversionClient
  ];

  programs.git = {
    enable = true;
    userName  = "dengfan";
    userEmail = "1310332521@qq.com";
  };
}
