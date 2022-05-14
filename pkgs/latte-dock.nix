{ dotfiles, pkgs, lib, cmake, xorg, fetchurl
, extra-cmake-modules }:

with pkgs.libsForQt5;
let
  conf = dotfiles.latte-dock.conf;
in
mkDerivation rec {
  pname = "latte-dock";
  version = "0.10.8";

  src = fetchurl {
    url = "https://download.kde.org/stable/${pname}/${pname}-${version}.tar.xz";
    sha256 = "00aab59d97b877f43292fc082c8bfe7f634b265cbee8ab5a2d2c78e0414c912a";
    name = "${pname}-${version}.tar.xz";
  };

  buildInputs = [
    plasma-framework
    xorg.libpthreadstubs
    xorg.libXdmcp
    xorg.libSM
  ];

  nativeBuildInputs =
  with pkgs.libsForQt5;
  [ extra-cmake-modules
    cmake
    karchive
    kwindowsystem
    qtx11extras
    kcrash
    knewstuff
    qt5.qttools
    qt5.wrapQtAppsHook
  ];
  # patches = [
  #   ./0001-close-user-autostart.patch
  # ];
  fixupPhase = ''
    mkdir -p $out/etc/xdg/autostart
    cp $out/share/applications/org.kde.latte-dock.desktop $out/etc/xdg/autostart
    cp ${conf} $out/share/plasma/shells/org.kde.latte.shell/contents/templates/Common.layout.latte
    wrapQtApp $out/bin/latte-dock
    '';
    # qtWrapperArgs = [
      # ''--set-default QT_QPA_PLATFORMTHEME qt5ct''
      # ''--set-default QT_QPA_PLATFORM xcb''
    # ];

  meta = with lib; {
    description = "Dock-style app launcher based on Plasma frameworks";
    homepage = "https://github.com/psifidotos/Latte-Dock";
    license = licenses.gpl2;
    platforms = platforms.unix;
    maintainers = [ maintainers.benley maintainers.ysndr ];
  };
}

# {pkgs, dotfiles, makeWrapper, ...}:
# let
#   latte-dock = pkgs.latte-dock.overrideAttrs (oldAttrs :{

#       buildInputs = oldAttrs.buildInputs or [] ++
#       ( with pkgs; [
#         libsForQt5.kimageformats
#         libsForQt5.qt5.qtsvg
#         libinput
#         qt5ct
#         libdrm
#         libinput
#         wayland
#         xwayland
#         egl-wayland
#         wayland-protocols
#         libsForQt5.plasma-wayland-protocols
#         libsForQt5.qt5.qtwayland
#       ]);

#       nativeBuildInputs = oldAttrs.nativeBuildInputs or [] ++ [
#         pkgs.libsForQt5.qt5.qttools

#         pkgs.libsForQt5.qt5.wrapQtAppsHook
#       ];
#       # dontWrapQtApps = true;
#       postInstall = oldAttrs.postInstall or "" +''
#         cp ${conf} $out/share/plasma/shells/org.kde.latte.shell/contents/templates/Common.layout.latte
#         wrapQtApp $out/bin/latte-dock
#       '';
#       qtWrapperArgs = [
#         ''--set-default QT_QPA_PLATFORMTHEME qt5ct''
#         ''--set-default QT_QPA_PLATFORM xcb''
#       ];
#     });

# in
# latte-dock

# pkgs.writeShellScriptBin "latte-dock" ''
#   # Call hello with a traditional greeting
#   mkdir /tmp/ld
#   export QT_DEBUG_PLUGINS=1
#   exec nohup ${latte-dock}/bin/latte-dock -dr > /tmp/ld/log &
# ''
