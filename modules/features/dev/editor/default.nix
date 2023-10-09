{ pkgs, mpkgs, ... }:

{

  environment.systemPackages = with pkgs;[
    vscode
    vim

    kate
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    # mpkgs.idea-ultimate
  ];

}
