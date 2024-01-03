{ pkgs, ...}:

{
  forEachAllSystems = pkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
  allSystemsPkgs = pkgs: buildPkgsFn: forEachAllSystems (system:
    let pkgs =
      import pkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in buildPkgsFn pkgs
  );
  buildPkgs = buildPkgsFn: allSystemsPkgs pkgs buildPkgsFn;
}
