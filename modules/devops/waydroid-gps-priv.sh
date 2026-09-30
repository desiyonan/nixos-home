# waydroid GPS privileged helper (root via sudoers NOPASSWD)
set -euo pipefail

wd_shell() {
  waydroid --details-to-stdout shell -- "$@"
}

is_num() {
  [[ "$1" =~ ^-?[0-9]+([.][0-9]+)?$ ]]
}

cmd="${1:-}"
shift || true

case "$cmd" in
  init)
    wd_shell settings put global hidden_api_policy 1
    wd_shell appops set io.appium.settings android:mock_location allow
    wd_shell pm grant io.appium.settings android.permission.ACCESS_FINE_LOCATION
    wd_shell pm grant io.appium.settings android.permission.ACCESS_COARSE_LOCATION
    wd_shell cmd appops set io.appium.settings android:mock_location allow || true
    ;;
  set)
    lat="${1:-}"
    lon="${2:-}"
    alt="${3:-0}"
    if ! is_num "$lat" || ! is_num "$lon" || ! is_num "$alt"; then
      echo "waydroid-gps-priv: latitude/longitude/altitude must be numeric" >&2
      exit 2
    fi
    wd_shell am start-foreground-service --user 0 \
      -n io.appium.settings/.LocationService \
      --es latitude "$lat" \
      --es longitude "$lon" \
      --es altitude "$alt"
    ;;
  clear)
    wd_shell am stopservice io.appium.settings/.LocationService
    ;;
  *)
    echo "waydroid-gps-priv: unknown command" >&2
    exit 2
    ;;
esac
