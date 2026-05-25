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

  /* 将 moduleDir 下子目录与顶层 .nix 文件（不含 default.nix）import 为 attrset，键为目录名或去后缀的文件名；同名时文件覆盖目录。 */
  attrModules = moduleDir: args:
    let
      entries = builtins.readDir moduleDir;
      dirNames = builtins.attrNames (lib.filterAttrs (n: t: t == "directory") entries);
      nixNames = builtins.attrNames (lib.filterAttrs
        (n: t: t == "regular" && n != "default.nix" && lib.hasSuffix ".nix" n)
        entries);
      fromDirs = lib.genAttrs dirNames (name: import (moduleDir + "/${name}") args);
      fromFiles = lib.listToAttrs (map (fname:
        lib.nameValuePair (lib.removeSuffix ".nix" fname)
          (import (moduleDir + "/${fname}") args))
        nixNames);
    in
    fromDirs // fromFiles;
}
