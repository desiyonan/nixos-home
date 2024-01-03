args:
rec
{
  user = import ./user.nix args;
  host = import ./host.nix args;
}
