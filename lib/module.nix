{ lib, mlib,... }:

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
          (name: type: type == "regular" && lib.hasSuffix name ".nix" && name != "default.nix")
          (builtins.readDir moduleDir)
        )
      );

  listModules = moduleDir: [] ++ (listModuleDirs moduleDir) ++ (listNixFiles moduleDir);
}
