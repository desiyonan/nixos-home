{pkgs, makeWrapper, ...}:
let
  ld = pkgs.latte-dock.overrideAttrs (oldAttrs :{
      buildInputs = oldAttrs.buildInputs or [] ++ [ pkgs.makeWrapper ];
      postInstall = oldAttrs.postInstall or "" +''
        wrapProgram $out/bin/latte-dock \
          --prefix QT_IM_MODULE : "xim"
      '';
    });
  conf = ./common.layout.latte;
  configDrv = pkgs.symlinkJoin {
    name = "latte-dock-config-${ld.version}";

    paths = [
      ld
    ];

    nativeBuildInput = [ pkgs.makeWrapper ];

    postInstall = ''
      wrapProgram $out/bin/latte-dock \
        --prefix QT_IM_MODULE : "xim"

    '';
      # $out/bin/latte-dock --import-layout ${conf}

    meta = ld.meta;
  };

in
{
  environment.systemPackages = [
    ld
    # configDrv
  ];
}
