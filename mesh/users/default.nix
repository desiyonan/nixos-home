{lib, ...}@args:
rec {
  dnf = import ./dnf.nix args;
  root = import ./root.nix args;
  defaults = [ dnf root ];
}
