{ lib, mlib, nixpkgs, root_inputs, ... }@args:
{
  mkHost = hostConfigs: users:
  let
    # networkCfg = builtins.listToAttrs (map (n: {
    #   name = "${n}";
    #   value = { useDHCP = true; };
    # }) NICs);
    sys_users = (map (u: mlib.mkSystemUser u) users);
  in lib.nixosSystem {
    specialArgs = {
      inherit lib mlib root_inputs;
    };
    modules = [
      # nixpkgs.nixosModules.notDetected
      (import ../configs hostConfigs)
      (import ../overlays)
    ] ++ sys_users;
  };
}
