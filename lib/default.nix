{...}@args: # flake self

finalLib: prevLib: # lib overlay
let
  inherit (prevLib) makeExtensible;

  mlib = makeExtensible(self:
    let
      callLibs = file: import file ({ lib = finalLib;} // args);
    in {
      host = callLibs ./host.nix;
      user = callLibs ./user.nix;
      pkg = callLibs ./pkg.nix;
      module = callLibs ./module.nix;

      inherit (self.host) mkHost;
      inherit (self.user) mkSystemUser;
      inherit (self.module) listModuleDirs listNixFiles listModules;
  });
in
{
  inherit mlib;
  inherit (mlib) host user pkg module;
  inherit (mlib) mkHost mkSystemUser listModuleDirs listNixFiles listModules;
}
