{
  lib,
  stdenv,
  buildGo126Module,
  fetchFromGitHub,
  autoPatchelfHook,
  copyDesktopItems,
  glib-networking,
  nodejs,
  pkg-config,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  wrapGAppsHook3,
  wails,
  webkitgtk_4_1,
  makeDesktopItem,
}:

let
  pname = "gui-for-singbox";
  version = "1.24.0";

  src = fetchFromGitHub {
    owner = "GUI-for-Cores";
    repo = "GUI.for.SingBox";
    tag = "v${version}";
    hash = "sha256-cC3nD8JYvwKVkfkAkPzU+/5MNesSFJ3x/WEi9JkdtdM=";
  };

  metaCommon = {
    homepage = "https://github.com/GUI-for-Cores/GUI.for.SingBox";
    hydraPlatforms = [ ];
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = [ ];
  };

  frontend = stdenv.mkDerivation (finalAttrs: {
    inherit pname version src;

    sourceRoot = "${finalAttrs.src.name}/frontend";

    patches = [ ./frontend-runtime-path.patch ];

    nativeBuildInputs = [
      nodejs
      pnpmConfigHook
      pnpm_10
    ];

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs)
        pname
        version
        src
        sourceRoot
        ;
      pnpm = pnpm_10;
      fetcherVersion = 3;
      hash = "sha256-VewOzWAJn1iav3YbJznHwtJk0d2c2EjHrC2xTsMVFfQ=";
    };

    buildPhase = ''
      runHook preBuild

      pnpm run build-only

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r dist $out

      runHook postInstall
    '';

    meta = metaCommon // {
      description = "GUI program developed by vue3";
      platforms = lib.platforms.all;
    };
  });
in

buildGo126Module {
  inherit pname version src;

  patches = [ ./xdg-path-and-restart-patch.patch ];

  doCheck = false;

  vendorHash = "sha256-9uWrctbQ+vujb1Q8zT7Bv7rVyNY1rCM577c9caOKRNo=";

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    pkg-config
    wails
    wrapGAppsHook3
  ];

  buildInputs = [
    glib-networking
    webkitgtk_4_1
  ];

  preBuild = ''
    cp -r ${frontend} frontend/dist
  '';

  buildPhase = ''
    runHook preBuild

    wails build -m -s -trimpath -skipbindings -devtools -tags webkit2_41 -o GUI.for.SingBox

    runHook postBuild
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "gui-for-singbox";
      exec = "GUI.for.SingBox";
      icon = "gui-for-singbox";
      genericName = "GUI.for.SingBox";
      desktopName = "GUI.for.SingBox";
      categories = [ "Network" ];
      keywords = [ "Proxy" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    install -Dm 0755 build/bin/GUI.for.SingBox $out/bin/GUI.for.SingBox
    install -Dm 0644 build/appicon.png $out/share/icons/hicolor/256x256/apps/gui-for-singbox.png

    runHook postInstall
  '';

  passthru = { inherit frontend; };

  meta = metaCommon // {
    description = "SingBox GUI program developed by vue3 + wails";
    mainProgram = "GUI.for.SingBox";
    platforms = lib.platforms.linux;
  };
}
