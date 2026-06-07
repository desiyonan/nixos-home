{
  lib,
  stdenv,
  fetchurl,
}:

let
  version = "0.9.6";
  platformPkg =
    if stdenv.hostPlatform.isx86_64 && stdenv.hostPlatform.isLinux then
      "codegraph-linux-x64"
    else if stdenv.hostPlatform.isAarch64 && stdenv.hostPlatform.isLinux then
      "codegraph-linux-arm64"
    else
      throw "codegraph: unsupported platform ${stdenv.hostPlatform.system}";
in
stdenv.mkDerivation {
  pname = "codegraph";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@colbymchenry/${platformPkg}/-/${platformPkg}-${version}.tgz";
    hash = if platformPkg == "codegraph-linux-x64" then
      "sha256-EOE2R5XysBf1GUGEVs4/vvXP8msVZx0iuaFqdhYdncY="
    else
      lib.fakeHash;
  };

  sourceRoot = "package";
  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "Pre-index your codebase for AI agents (@colbymchenry/codegraph)";
    homepage = "https://github.com/colbymchenry/codegraph";
    license = licenses.mit;
    mainProgram = "codegraph";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = [ ];
  };
}
