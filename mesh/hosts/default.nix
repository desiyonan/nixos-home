{lib, ...}@args:
let
  users = import ../users args;
  gw = import ./gw args;
  ws = import ./ws args;
  s60 = import ./s60 args;
  s62 = import ./s62 args;
  s71 = import ./s71 args;
  s72 = import ./s72 args;
  withUsers = host: [ host ] ++ users.defaults;
in
{
  gw = lib.mkHost (withUsers gw);
  ws = lib.mkHost (withUsers ws);
  s60 = lib.mkHost (withUsers s60);
  s62 = lib.mkHost (withUsers s62);
  s71 = lib.mkHost (withUsers s71);
  s72 = lib.mkHost (withUsers s72);
}
