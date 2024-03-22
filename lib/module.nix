{ lib, mlib }:

{
  listModuleDirs = {path ? ./.}:
    builtins.map
      (d: ./. + "/${d}")
      (builtins.attrNames
        (filterAttrs
          (name: type: type == "directory")
          (builtins.readDir path)
        )
      );

  listNixFiles = {path ? ./.}:
    builtins.map
      (f: ./. + "/${f}")
      (builtins.attrNames
        (filterAttrs
          (name: type: type == "regular" && hasSuffix name ".nix" && name != "default.nix")
          (builtins.readDir path)
        )
      );

  listModules = {path ? ./.}@ins: [] ++ (listModuleDirs ins) ++ (listNixFiles ins);
}
