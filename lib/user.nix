{ lib, mlib }:
with builtins;
{
  mkSystemUser = { name, groups, uid, ... }:
  {
    users.users."${name}" = {
      name = name;
      isNormalUser = true;
      isSystemUser = false;
      extraGroups = groups;
      uid = uid;
      initialPassword = "password";
    };
  };
}
