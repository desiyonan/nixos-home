{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  patchelf,
  zlib,
  bubblewrap,
  writeShellScript,
  makeWrapper,
  util-linux,
}:

# 亿格云枢 Linux 客户端（Thundersoft 企业码，Ubuntu x86_64）。
# 二进制写死 /opt/apps/yunshu。daemon / CLI 只依赖 glibc 和 zlib，才能改解析和路由。
# 不执行上游 postinst（chattr、ld.so.preload、dpkg 钩子）。
# 宿主机 /lib64/ld-linux 是 nix-ld，NixOS 26.05 的 glib 也是 2.88。界面启动时用
# bubblewrap 把这个加载器换成 Ubuntu 24.04 的 ld-linux，并让它只搜索同一套 Ubuntu 库。
# 这套库只挂进界面沙箱的 /lib，不进系统 FHS，避免盖住 Nix glibc。
let
  version = "2.3.10.30";
  corpCode = "Thundersoft";

  # 优先级只在这份库目录里生效。不要铺进 FHS 的 /usr/lib，否则会盖住 Nix glibc。
  ubuntuGuiLibs = import ./ubuntu-gui-libs.nix { inherit stdenv fetchurl dpkg; };

  unwrapped = stdenv.mkDerivation {
    pname = "yunshu-unwrapped";
    inherit version;

    src = fetchurl {
      url = "https://pkg-cdn-hz0.sase.eagleyun.com/app/linux/${version}/ubuntu/x86_64/eaglecloud_yunshu_${version}_amd64.deb";
      hash = "sha256-bXf7y9N8gybnKu2fk6HmNZtjLU+EK5RaBrCiW/sk5yo=";
    };

    nativeBuildInputs = [
      dpkg
      patchelf
    ];

    unpackPhase = ''
      runHook preUnpack
      dpkg-deb -x "$src" .
      runHook postUnpack
    '';

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -a opt "$out/opt"
      chmod -R u+w "$out/opt"
      find "$out/opt" -perm -4000 -exec chmod a-s {} +

      interp="$(< "$NIX_CC/nix-support/dynamic-linker")"
      rpath="${
        lib.makeLibraryPath [
          zlib
          stdenv.cc.cc.lib
        ]
      }"
      for bin in yunshu yunshu-daemon yunshu-updater; do
        patchelf \
          --set-interpreter "$interp" \
          --set-rpath "$rpath" \
          "$out/opt/apps/yunshu/files/bin/$bin"
        chmod 755 "$out/opt/apps/yunshu/files/bin/$bin"
      done
      # 准入页会 fork worker，并且用 {env:{action}} 换掉整个环境，LD_LIBRARY_PATH 进不去。
      # 插件没有 RUNPATH，libsdk.so 又在同目录，所以这里写成 $ORIGIN。
      patchelf --set-rpath '$ORIGIN' \
        "$out/opt/apps/yunshu/files/resources/app.asar.unpacked/node_modules/sdk/ysapi_node.linux-x64-gnu.node"
      runHook postInstall
    '';
  };

  libPath = lib.makeLibraryPath [
    zlib
    stdenv.cc.cc.lib
  ];

  # 占位符在安装阶段换成界面入口。root 直接跑没有用户会话总线。
  launch = writeShellScript "yunshu-launch" ''
    set -euo pipefail
    fhs="@fhs@"
    runuser="@runuser@"
    if [[ "$(id -u)" -eq 0 ]]; then
      for runtime in /run/user/*; do
        uid=$(basename "$runtime")
        [[ "$uid" =~ ^[0-9]+$ ]] || continue
        (( uid >= 1000 )) || continue
        [[ -S "$runtime/bus" ]] || continue
        user=$(getent passwd "$uid" | cut -d: -f1)
        home=$(getent passwd "$uid" | cut -d: -f6)
        [[ -n "$user" && -n "$home" ]] || continue
        display="''${DISPLAY-}"
        wayland="''${WAYLAND_DISPLAY-}"
        [[ -n "$display" ]] || display=:0
        [[ -n "$wayland" ]] || wayland=wayland-0
        exec "$runuser" -u "$user" -- \
          env HOME="$home" USER="$user" LOGNAME="$user" \
          XDG_RUNTIME_DIR="$runtime" \
          DBUS_SESSION_BUS_ADDRESS="unix:path=$runtime/bus" \
          DISPLAY="$display" \
          WAYLAND_DISPLAY="$wayland" \
          "$0" "$@"
      done
    fi
    exec "$fhs" "$@"
  '';

  entry = writeShellScript "yunshu-entry" ''
    set -euo pipefail
    cfg="''${XDG_CONFIG_HOME:-$HOME/.config}/YunshuCross"
    mkdir -p "$cfg"
    if [[ ! -s "$cfg/config.json" ]]; then
      printf '%s\n' '{"yunshuCorpcode":"${corpCode}"}' > "$cfg/config.json"
    fi
    # 界面插件 ysapi_node 依赖同目录的 libsdk.so，自身没有 RUNPATH。
    sdk="/opt/apps/yunshu/files/resources/app.asar.unpacked/node_modules/sdk"
    libs="${ubuntuGuiLibs}/lib"
    # 缺省控制面地址。文件不存在时界面会抛 ENOENT，但默认值就是这个。
    ctl="/opt/apps/yunshu/files/config/private_ctl.conf"
    if [[ ! -s "$ctl" && -w "$(dirname "$ctl")" ]]; then
      printf '%s\n' "https://sp.eagleyun.cn/" > "$ctl"
    fi
    # 会话把 GTK 指到 Wayland，Electron 21 却画不出窗口。改走 XWayland。
    # 程序自己会 disableHardwareAcceleration，不要再加 --in-process-gpu，否则主线程空转、登录窗不出现。
    # 准入、连接这些调用会 fork worker.js，并且只留下 action/args1 两个环境变量。
    # 子进程因此没有 LD_LIBRARY_PATH。把同一套库挂到 Ubuntu 加载器的默认目录 /lib
    # （这个沙箱里的 /lib，不改宿主机）。主进程仍保留原来的环境变量。
    nixld=$(readlink -f /lib64/ld-linux-x86-64.so.2)
    pixbuf=$(echo "$libs"/gdk-pixbuf-2.0/*/loaders)
    exec ${bubblewrap}/bin/bwrap --dev-bind / / \
      --ro-bind "$libs/ld-linux-x86-64.so.2" "$nixld" \
      --ro-bind "$libs" /lib \
      --setenv GDK_BACKEND x11 \
      --unsetenv WAYLAND_DISPLAY \
      --setenv LD_LIBRARY_PATH "$libs:$sdk" \
      --setenv GIO_MODULE_DIR "$libs/gio/modules" \
      --setenv GDK_PIXBUF_MODULEDIR "$pixbuf" \
      -- /opt/apps/yunshu/files/yunshu-cross --disable-http2 --no-sandbox --ozone-platform=x11 "$@"
  '';
in
stdenv.mkDerivation {
  pname = "yunshu";
  inherit version;
  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p \
      "$out/bin" \
      "$out/share/applications" \
      "$out/share/icons/hicolor/256x256/apps" \
      "$out/lib/systemd/system"

    cp "${unwrapped}/opt/apps/yunshu/entries/icons/hicolor/scalable/apps/yunshu.png" \
      "$out/share/icons/hicolor/256x256/apps/yunshu.png"

    makeWrapper "${unwrapped}/opt/apps/yunshu/files/bin/yunshu-daemon" \
      "$out/bin/yunshu-daemon" \
      --prefix LD_LIBRARY_PATH : "${libPath}:${unwrapped}/opt/apps/yunshu/files:${unwrapped}/opt/apps/yunshu/files/plugin:${unwrapped}/opt/apps/yunshu/files/plugin/savapi"

    makeWrapper "${unwrapped}/opt/apps/yunshu/files/bin/yunshu-updater" \
      "$out/bin/yunshu-updater" \
      --prefix LD_LIBRARY_PATH : "${libPath}:${unwrapped}/opt/apps/yunshu/files:${unwrapped}/opt/apps/yunshu/files/plugin:${unwrapped}/opt/apps/yunshu/files/plugin/savapi"

    makeWrapper "${unwrapped}/opt/apps/yunshu/files/bin/yunshu" \
      "$out/bin/yunshu-cli" \
      --prefix LD_LIBRARY_PATH : "${libPath}:${unwrapped}/opt/apps/yunshu/files:${unwrapped}/opt/apps/yunshu/files/plugin:${unwrapped}/opt/apps/yunshu/files/plugin/savapi"

    # root 没有用户会话总线，Electron 会解析失败并退掉 GPU 进程。
    sed -e "s#@fhs@#${entry}#g" -e "s#@runuser@#${util-linux}/bin/runuser#g" \
      ${launch} > "$out/bin/yunshu"
    chmod 755 "$out/bin/yunshu"

    cat > "$out/share/applications/yunshu.desktop" <<EOF
    [Desktop Entry]
    Type=Application
    Version=${version}
    Name=云枢
    GenericName=云枢
    Comment=云枢 Linux 零信任客户端
    Exec=$out/bin/yunshu
    Icon=yunshu
    Terminal=false
    Categories=Network;
    StartupNotify=false
    EOF

    cat > "$out/lib/systemd/system/yunshu-daemon.service" <<EOF
    [Unit]
    Description=云枢
    After=network-online.target yunshu-sync.service
    Wants=network-online.target
    Requires=yunshu-sync.service

    [Service]
    Type=simple
    ExecStart=$out/bin/yunshu-daemon
    Restart=on-failure
    RestartSec=5s

    [Install]
    WantedBy=multi-user.target
    EOF
    runHook postInstall
  '';

  passthru = {
    inherit unwrapped corpCode;
  };

  meta = {
    description = "亿格云枢 Linux 客户端（Ubuntu x86_64）";
    homepage = "https://www.eagleyun.com";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "yunshu";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
