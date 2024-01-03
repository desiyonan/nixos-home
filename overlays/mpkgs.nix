{nixpkgs, ...}:

final: prev:
let
  dotfiles = import ../dotfiles;
  mpkgs = import ../pkgs {
    inherit dotfiles;
    pkgs = final;
  };

  mlibs = import ../lib {
    inherit nixpkgs;
    pkgs = final;
  };

  hosts = import ../hosts ;
  users = import ../users {pkgs = final;};
  defaultUsers = [users.default];
in rec {
  # specialArgs = pkgs;
  inherit mpkgs;
  mesh = rec {
    inherit dotfiles mpkgs mlibs hosts users defaultUsers;
  };
  lib = prev.lib // {mkSystemUser = mesh.mlibs.user.mkSystemUser;};
}
