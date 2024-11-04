{ pkgs,  ... }:

{

  environment.systemPackages = with pkgs;[
    vscode
    vim

    kate
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    jetbrains.rust-rover
    jetbrains.datagrip
  ];

}
