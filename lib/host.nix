{ lib, inputs, ... }@args:
{
  mkHost = hostConfigs: users:
  let
    sys_users = (map (u: lib.mkSystemUser u) users);
  in lib.nixosSystem {
    specialArgs = {
      inherit lib inputs;
    };
    modules = [
      # nixpkgs.nixosModules.notDetected
      (import ../configs hostConfigs)
      (import ../overlays)
    ] ++ sys_users;
  };
}
