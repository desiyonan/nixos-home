
{ config, pkgs, ... }:

{

  programs = {
    git = {
      # package = pkgs.gitAndTools.gitFull;
      enable = true;
      userName = "dnf";
      userEmail = "1310332521@qq.com";
      aliases = {
        ckt = "checkout";
        cmt = "commit";
        cma = "commit --amend";
        s = "status";
        st = "status";
        b = "branch";
        pl = "pull --rebase";
        pu = "push";
      };
      ignores = [ "*~" "*.swp" ];
      extraConfig = {
        init.defaultBranch = "master";
        core.editor = "vim";
        #protocol.keybase.allow = "always";
        credential.helper = "store --file ~/.git-credentials";
        pull.rebase = "true";
      };
    };
  };
}
