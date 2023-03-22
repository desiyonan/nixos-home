{pkgs,...}:
rec
{
  dnf = import ./dnf.nix {inherit pkgs;};

  default = dnf;
}
