{pkgs, lib, mlibs, ...}:
with lib;
{
  imports = mlibs.module.listModules {path=./.;};
}
