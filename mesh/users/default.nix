rec {
  dnf = import ./dnf.nix;
  defaults = [dnf];
}
