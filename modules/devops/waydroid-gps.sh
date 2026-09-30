set -euo pipefail

usage() {
  cat <<'EOF'
用法:
  waydroid-gps init
  waydroid-gps <纬度> <经度> [海拔]
  waydroid-gps set <纬度> <经度> [海拔]
  waydroid-gps host
  waydroid-gps clear

示例:
  waydroid-gps init
  waydroid-gps 31.2304 121.4737
  waydroid-gps host
EOF
}

need_session() {
  if ! waydroid status 2>/dev/null | grep -q '^Session:[[:space:]]*RUNNING'; then
    echo "waydroid-gps: Waydroid session 未运行，先 waydroid session start / show-full-ui" >&2
    exit 1
  fi
}

priv() {
  /run/wrappers/bin/sudo -n "${WAYDROID_GPS_PRIV:?}" "$@"
}

cmd="${1:-}"

case "$cmd" in
  -h | --help | help | "")
    usage
    exit 0
    ;;
  init)
    need_session
    if [[ -z "${APPIUM_APK:-}" || ! -f "$APPIUM_APK" ]]; then
      echo "waydroid-gps: Appium Settings APK 不存在" >&2
      exit 1
    fi
    waydroid app install "$APPIUM_APK"
    priv init
    echo "已安装 mock GPS（io.appium.settings），可用：waydroid-gps <纬度> <经度>"
    ;;
  set)
    shift
    lat="${1:-}"
    lon="${2:-}"
    alt="${3:-0}"
    if [[ -z "$lat" || -z "$lon" ]]; then
      usage >&2
      exit 2
    fi
    need_session
    priv set "$lat" "$lon" "$alt"
    echo "已模拟 GPS: $lat, $lon${alt:+, alt $alt}"
    ;;
  host)
    need_session
    priv set "${HOST_LAT:?}" "${HOST_LON:?}" 0
    echo "已模拟 GPS（主机 location）: ${HOST_LAT}, ${HOST_LON}"
    ;;
  clear | stop)
    need_session
    priv clear
    echo "已停止模拟 GPS"
    ;;
  *)
    if [[ "$cmd" =~ ^-?[0-9] ]]; then
      lat="$cmd"
      lon="${2:-}"
      alt="${3:-0}"
      if [[ -z "$lon" ]]; then
        usage >&2
        exit 2
      fi
      need_session
      priv set "$lat" "$lon" "$alt"
      echo "已模拟 GPS: $lat, $lon${alt:+, alt $alt}"
    else
      usage >&2
      exit 2
    fi
    ;;
esac
