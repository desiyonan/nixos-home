{pkgs, dotfiles, makeWrapper, ...}:
let
  conf = dotfiles.latte-dock.conf;
  latte-dock = pkgs.latte-dock.overrideAttrs (oldAttrs :{
      buildInputs = oldAttrs.buildInputs or [] ++
      ( with pkgs; [
        libsForQt5.kimageformats
        libsForQt5.qt5.qtsvg
        libinput
        qt5ct
        libdrm
        libinput
        wayland
        xwayland
        egl-wayland
        wayland-protocols
        libsForQt5.plasma-wayland-protocols
        libsForQt5.qt5.qtwayland
      ]);

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
        ''--set-default QT_QPA_PLATFORMTHEME qt5ct''
        ''--set-default QT_QPA_PLATFORM xcb''
      ];
    });

in
latte-dock
# pkgs.writeShellScriptBin "latte-dock" ''
#   # Call hello with a traditional greeting
#   mkdir /tmp/ld
#   export QT_DEBUG_PLUGINS=1
#   exec nohup ${latte-dock}/bin/latte-dock -dr > /tmp/ld/log &
# ''
