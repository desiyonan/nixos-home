{ pkgs, mpkgs, ... }:

{
  imports = [
    ../packages/vscode.nix
    ../packages/openssh.nix
  ];


  environment.systemPackages = [
    pkgs.jdk8
    pkgs.jdk11
    pkgs.maven
    pkgs.git
    pkgs.gh

    mpkgs.idea-ultimate
  ];

}
