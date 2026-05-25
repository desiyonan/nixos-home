{lib, ...}@args:
rec {
  dnf = import ./dnf.nix args;
  defaults = [dnf];
}
