{ pkgs, home-manager, lib, system, overlays, ... }:
with builtins;
{
  mkHMUser = { # To be completed later };

  mkSystemUser = { name, groups, uid, shell, ... }:
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
