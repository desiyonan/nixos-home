{pkgs, dotfiles, makeWrapper, ...}:
let
  conf = dotfiles.latte-dock.conf;
  latte-dock = pkgs.latte-dock.overrideAttrs (oldAttrs :{
      nativeBuildInputs = oldAttrs.nativeBuildInputs or [] ++ [
        pkgs.libsForQt5.qt5.qttools

        pkgs.libsForQt5.qt5.wrapQtAppsHook
      ];
      # dontWrapQtApps = true;
      postInstall = oldAttrs.postInstall or "" +''
        cp ${conf} $out/share/plasma/shells/org.kde.latte.shell/contents/templates/Common.layout.latte
        wrapQtApp $out/bin/latte-dock
      '';
      qtWrapperArgs = [
        ''--set QT_IM_MODULE xim''
        ''--set-default QT_QPA_PLATFORM xcb''
      ];
    });

in latte-dock
