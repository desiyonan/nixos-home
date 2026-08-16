{
  lib,
  python3Packages,
  fetchFromGitHub,
  qt6,
  bluez,
}:

python3Packages.buildPythonApplication rec {
  pname = "bluelock";
  version = "0.5.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "gunchev";
    repo = "bluelock";
    rev = "v${version}";
    hash = "sha256-BHP70YoTd8WTshVCdvQvKMZ/2Byc0T3WST1d+1T2qtQ=";
  };

  patches = [ ./proximity-modes.patch ];

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
  ];

  build-system = [ python3Packages.hatchling ];

  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
    qt6.qtwayland
  ];

  dependencies = with python3Packages; [
    pyqt6
    dbus-python
  ];

  pythonImportsCheck = [ "bluelock" ];
  doCheck = false;

  dontWrapQtApps = true;
  makeWrapperArgs = [
    "\${qtWrapperArgs[@]}"
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ bluez ])
  ];

  meta = {
    description = "Lock and unlock a KDE session based on Bluetooth device proximity";
    homepage = "https://github.com/gunchev/bluelock";
    license = lib.licenses.unlicense;
    mainProgram = "bluelock";
    platforms = lib.platforms.linux;
  };
}
