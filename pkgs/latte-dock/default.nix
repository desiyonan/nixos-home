{ mkDerivation, lib, cmake, xorg, plasma-framework, plasma-wayland-protocols, fetchFromGitLab,
extra-cmake-modules, karchive, kwindowsystem, qtx11extras, qtwayland, kcrash, knewstuff, wayland,
dotfiles, pkgs
 }:

let
  conf = dotfiles.latte-dock.conf;
in
mkDerivation rec {
  pname = "latte-dock";
  version = "unstable-2022-09-06";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma";
    repo = "latte-dock";
    rev = "cd36798a61a37652eb549d7dfcdf06d2028eddc4";
    sha256 = "sha256-X2PzI2XJje4DpPh7gTtYnMIwerR1IDY53HImvEtFmF4=";
  };

  buildInputs = [ 
    plasma-framework
    plasma-wayland-protocols
    qtwayland
    xorg.libpthreadstubs 
    xorg.libXdmcp
    xorg.libSM 
    wayland 
    ];

  # nativeBuildInputs =
  # with pkgs.libsForQt5;
  # [ extra-cmake-modules
  #   cmake
  #   karchive
  #   kwindowsystem
  #   qtx11extras
  #   kcrash
  #   knewstuff
  #   qt5.qttools
  #   qt5.wrapQtAppsHook
  # ];


  nativeBuildInputs = [ 
    extra-cmake-modules
    cmake
    karchive
    kwindowsystem
    qtx11extras 
    kcrash 
    knewstuff 
  ];

  patches = [
    ./0001-close-user-autostart.patch
  ];
  
  postInstall = ''
    mkdir -p $out/etc/xdg/autostart
    cp $out/share/applications/org.kde.latte-dock.desktop $out/etc/xdg/autostart
    cp ${conf} $out/share/plasma/shells/org.kde.latte.shell/contents/templates/Custom.layout.latte
    '';
    # wrapQtApp $out/bin/latte-dock
    # qtWrapperArgs = [
      # ''--set-default QT_QPA_PLATFORMTHEME qt5ct''
      # ''--set-default QT_QPA_PLATFORM xcb''
    # ];

  meta = with lib; {
    description = "Dock-style app launcher based on Plasma frameworks";
    homepage = "https://github.com/psifidotos/Latte-Dock";
    license = licenses.gpl2;
    platforms = platforms.unix;
    maintainers = [ maintainers.ysndr ];
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
