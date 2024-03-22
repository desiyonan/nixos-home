{lib}:
let
  mlib = lib.makeExtensible(self: let
      callLibs = file: import file {
        inherit lib;
        mlib = self;
      };
    in {
      host = callLibs ./host.nix;
      user = callLibs ./user.nix;
      pkg = callLibs ./pkg.nix;
      module = callLibs ./module.nix;

      inherit (self.host) mkHost;
      inherit (self.user) mkSystemUser;
      inherit (self.module) listModuleDirs listNixFiles listModules;
  });
  extendLib = lib.extend (final: prev: {
    inherit mlib;
    inherit (mlib) host user pkg module;

    inherit (mlib) mkHost mkSystemUser listModuleDirs listNixFiles listModules;
  });
in extendLib
