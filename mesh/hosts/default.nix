{lib, ...}@args:
let
  users = import ../users args;
  gw = import ./gw args;
  ws = import ./ws args;
  s71 = import ./s71 args;
  withUsers = host: [ host ] ++ users.defaults;
in
{
  gw = lib.mkHost (withUsers gw);
  ws = lib.mkHost (withUsers ws);
  s71 = lib.mkHost (withUsers s71);
}
