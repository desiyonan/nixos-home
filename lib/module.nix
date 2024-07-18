{ lib, ... }:

rec {
  listModuleDirs = moduleDir:
    builtins.map
      (d: moduleDir + "/${d}")
      (builtins.attrNames
        (lib.filterAttrs
          (name: type: type == "directory")
          (builtins.readDir moduleDir)
        )
      );

  listNixFiles = moduleDir:
    builtins.map
      (f: moduleDir + "/${f}")
      (builtins.attrNames
        (lib.filterAttrs
          (name: type: type == "regular" && name != "default.nix" && lib.hasSuffix ".nix" name)
          (builtins.readDir moduleDir)
        )
      );

  listModules = moduleDir: [] ++ (listModuleDirs moduleDir) ++ (listNixFiles moduleDir);

  importModules = moduleDir: args:
    builtins.map
      (m: import m args)
      (listModules moduleDir);
}
