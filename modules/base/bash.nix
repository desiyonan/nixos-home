{ pkgs, ... }:

{

  programs.bash = {
    completion.enable = true;
    promptInit = pkgs.mesh.dotfs.shell.prompt;

    shellAliases = { };
  };

  # environment.binsh = "${pkgs.bash}/bin/bash";
}
