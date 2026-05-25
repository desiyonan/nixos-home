{ lib, stdenvNoCC, fetchzip }:

stdenvNoCC.mkDerivation rec {
  pname = "spotbugs";
  version = "4.9.8";

  src = fetchzip {
    url = "https://github.com/spotbugs/spotbugs/releases/download/${version}/spotbugs-${version}.zip";
    hash = "sha256-w4GdgPXOX8nrp1uNuNzVPXEICwHE/x5y4sQWg5+94dc=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp -r $src/bin/* $out/bin/
    chmod +x $out/bin/*
  '';

  meta = {
    description = "Static analysis tool for Java bytecode";
    homepage = "https://spotbugs.github.io/";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
