{pkgs, dotfiles, makeWrapper, ...}:
let
  conf = dotfiles.latte-dock.conf;
  latte-dock = pkgs.latte-dock.overrideAttrs (oldAttrs :{
      buildInputs = oldAttrs.buildInputs or [] ++ [
          pkgs.libsForQt5.fcitx5-qt
          pkgs.libsForQt5.qt5.qtbase
          ];
      nativeBuildInputs = oldAttrs.nativeBuildInputs or [] ++ [
        pkgs.libsForQt5.qt5.wrapQtAppsHook
      ];
      dontWrapQtApps = true;
      postFixup = oldAttrs.postInstall or "" +''
        cp ${conf} $out/share/plasma/shells/org.kde.latte.shell/contents/templates/Common.layout.latte
        wrapProgram bin/latte-dock \
          --set-default QT_QPA_PLATFORM wayland \
          --set-default QT_IM_MODULE xim \
          --set-default QT_QPA_PLATFORMTHEME qt5ct
      '';
      qtWrapperArgs = [
        # ''--set QT_QPA_PLATFORM wayland''
        # ''--set QT_IM_MODULE xim''
        # ''--set-default QT_QPA_PLATFORMTHEME qt5ct''
        # ''--set QT_PLUGIN_PATH=/home/dnf/.nix-profile/lib/qt4/plugins:/home/dnf/.nix-profile/lib/kde4/plugins:/etc/profiles/per-user/dnf/lib/qt4/plugins:/etc/profiles/per-user/dnf/lib/kde4/plugins:/nix/var/nix/profiles/default/lib/qt4/plugins:/nix/var/nix/profiles/default/lib/kde4/plugins:/run/current-system/sw/lib/qt4/plugins:/run/current-system/sw/lib/kde4/plugins''
      ];
    });

in latte-dock
