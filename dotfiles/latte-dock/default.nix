{ symlinkJoin, makeWrapper, latte-dock, ...}:

symlinkJoin {
  name = "dnf-latte-dock-${latte-dock.version}";

  paths = [
    latte-dock
  ];

  nativeBuildInput = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/latte-dock \
      --prefix QT_IM_MODULE : "xim"

  '';
    # $out/bin/latte-dock --import-layout ./ws.layout.latte

  meta = latte-dock.meta;
}
