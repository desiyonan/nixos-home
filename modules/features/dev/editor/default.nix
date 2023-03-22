{ pkgs, mpkgs, ... }:

{

  environment.systemPackages = with pkgs;[
    vscode
    vim

    kate
    mpkgs.idea-ultimate
  ];

}
