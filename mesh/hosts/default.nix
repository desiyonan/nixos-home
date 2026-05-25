{lib, ...}@args:
let
  users = import ../users args;
  ws = import ./ws args;
  withUsers = host: [ host ] ++ users.defaults;
in
{
  ws = lib.mkHost (withUsers ws);
}
