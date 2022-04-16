{pkgs, dotfiles, makeWrapper, ...}:
let
  conf = dotfiles.latte-dock.conf;
  latte-dock = pkgs.latte-dock.overrideAttrs (oldAttrs :{
      buildInputs = oldAttrs.buildInputs or [] ++ [ pkgs.makeWrapper ];
      postInstall = oldAttrs.postInstall or "" +''
        cp ${conf} $out/share/plasma/shells/org.kde.latte.shell/contents/templates/Common.layout.latte
        cp ${conf} $out/share/plasma/shells/org.kde.latte.shell/contents/templates/Default.layout.latte
        wrapProgram $out/bin/latte-dock \
          --set QT_QPA_PLATFORMTHEME qt5ct \
          --set QT_IM_MODULE fcitx \
      '';
    });

in latte-dock
