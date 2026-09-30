{ config, lib, pkgs, ... }:

let
  cfg = config.modules.develop;

  buildTools = pkgs.stdenvNoCC.mkDerivation {
    pname = "android-sdk-build-tools";
    version = "35.0.0";

    src = pkgs.fetchurl {
      url = "https://dl.google.com/android/repository/build-tools_r35_linux.zip";
      sha1 = "2cfaa0bbb2336e9ec18ed3ecea84fa2e2af607bc";
    };

    nativeBuildInputs = [ pkgs.unzip ];

    dontConfigure = true;
    dontBuild = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/android-sdk/build-tools/35.0.0
      cp -a . "$out/libexec/android-sdk/build-tools/35.0.0/"
      runHook postInstall
    '';
  };

  # toolsdir 父目录必须叫 cmdline-tools；build-tools 供 aapt2
  androidSdkRoot = pkgs.runCommand "android-sdk-root" { } ''
    mkdir -p $out/cmdline-tools/latest $out/build-tools
    ln -s ${pkgs.android-studio-tools}/lib $out/cmdline-tools/latest/lib
    ln -s ${pkgs.android-studio-tools}/source.properties $out/cmdline-tools/latest/source.properties
    ln -s ${buildTools}/libexec/android-sdk/build-tools/35.0.0 $out/build-tools/35.0.0
  '';

  apkanalyzer = pkgs.writeScriptBin "apkanalyzer" ''
    #!${pkgs.runtimeShell}
    TOOLS_DIR="${androidSdkRoot}/cmdline-tools/latest"
    exec "${pkgs.jdk21}/bin/java" \
      -Dcom.android.sdklib.toolsdir="$TOOLS_DIR" \
      -classpath "$TOOLS_DIR/lib/apkanalyzer-classpath.jar" \
      com.android.tools.apk.analyzer.ApkAnalyzerCli "$@"
  '';
in
{
  config = lib.mkIf (cfg.enable && cfg.android.enable) {
    environment.systemPackages = [ apkanalyzer ];

    environment.variables = {
      ANDROID_SDK_ROOT = "${androidSdkRoot}";
      ANDROID_HOME = "${androidSdkRoot}";
    };
  };
}
