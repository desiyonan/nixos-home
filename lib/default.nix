{ nixpkgs, ... }@args:
let
  lib = nixpkgs.lib;
  overlay = finalLib: _prevLib:
    let
      callLibs = file: import file ({lib = finalLib;} // args);
      roots = {
        host = callLibs ./host.nix;
        module = callLibs ./module.nix;
      };
    in
    # 用 // 合併子模組導出的頂層鍵；右側覆蓋同名鍵
    roots // roots.host // roots.module;
in
lib.extend overlay
