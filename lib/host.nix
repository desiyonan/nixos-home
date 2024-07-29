{ lib, inputs, outputs, ... }@args:
{
  mkHost = hostConfigs: users:
  let
    sys_users = (map (u: lib.mkSystemUser u) users);
  in lib.nixosSystem {
    specialArgs = args;
    modules = [
      # nixpkgs.nixosModules.notDetected
      (import ../configs hostConfigs)
      (import ../overlays)
      (inputs.secret-hub.nixosModules.default)
    ] ++ sys_users;
  };
}
