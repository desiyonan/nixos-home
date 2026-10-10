{nixpkgs, ...}:

final: prev:
let
  mpkgs = import ../pkgs {
    inherit nixpkgs;
    pkgs = prev;
    lib = prev.lib;
  };
in
{
  inherit mpkgs;
  # 不稳定版才有 Node 24 / pnpm 11。Nixpkgs 的打包 PR 尚未合并。
  deepseek-harness = final.unstable.callPackage ../pkgs/deepseek-harness { };
} // mpkgs
