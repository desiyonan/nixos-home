{ pkgs,  ... }:

{

  environment.systemPackages = with pkgs;[
    vscode
    vim

    #kate
    kdePackages.kate

    jetbrains.idea
    jetbrains.pycharm
    jetbrains.rust-rover
    jetbrains.datagrip
    code-cursor
  ];

}
