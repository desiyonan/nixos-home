{pkgs,...}:

let
  ## 太新了 管的严
  # jetbrains.idea-ultimate
  myidea-ultimate = with pkgs ; jetbrains.idea-ultimate.overrideAttrs ( oldAttrs: rec {
      version = "2021.2";
      name = "idea-ultimate-${version}";
      src = fetchurl {
        url = "https://download.jetbrains.com/idea/ideaIU-${version}-no-jbr.tar.gz";
        sha256 = "554e0613e69fcb94d899329305df3b8ae0a96604af70ed77034a44e49e0d7d3d";
      };
    });
in myidea-ultimate
