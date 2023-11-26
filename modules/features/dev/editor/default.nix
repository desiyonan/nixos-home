{ pkgs, mpkgs, ... }:

{

  environment.systemPackages = with pkgs;[
    vscode
    vim

    kate
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    jetbrains.reust-cover
    # mpkgs.idea-ultimate
  ];

}
