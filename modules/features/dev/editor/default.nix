{ pkgs, mpkgs, ... }:

{

  environment.systemPackages = with pkgs;[
    vscode
    vim

    kate
    jetbrains.idea-ultimate
    # mpkgs.idea-ultimate
  ];

}
