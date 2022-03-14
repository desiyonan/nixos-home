{pkgs, makeWrapper, ...}:
let
  conf = ./common.layout.latte;
  latte-dock = pkgs.latte-dock.overrideAttrs (oldAttrs :{
      buildInputs = oldAttrs.buildInputs or [] ++ [ pkgs.makeWrapper ];
      postInstall = oldAttrs.postInstall or "" +''
        cp ${conf} $out/share/plasma/shells/org.kde.latte.shell/contents/templates/Common.layout.latte
        cp ${conf} $out/share/plasma/shells/org.kde.latte.shell/contents/templates/Default.layout.latte
        wrapProgram $out/bin/latte-dock \
          --prefix QT_IM_MODULE : "xim"
      '';
    });

in latte-dock
