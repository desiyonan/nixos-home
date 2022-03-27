{ pkgs, ... }:
with builtins;
{
  mkSystemUser = { name, groups, uid, shell?pkgs.bash, ... }:
  {
    users.users."${name}" = {
      name = name;
      isNormalUser = true;
      isSystemUser = false;
      extraGroups = groups;
      uid = uid;
      initialPassword = "password";
      shell = shell;
    };
  };
  
}
