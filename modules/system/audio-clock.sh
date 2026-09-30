set -euo pipefail

SYS_PS=/sys/module/snd_hda_intel/parameters/power_save
SYS_PSC=/sys/module/snd_hda_intel/parameters/power_save_controller

usage() {
  cat <<'EOF'
用法:
  audio-clock status
  audio-clock auto              # 取消强制采样率，按流自动升到 48/96/192
  audio-clock 48|96|192         # 强制图时钟（kHz）
  audio-clock powersave on|off  # HDA 运行时休眠（off=持续满性能，需 sudo）

当前会话立即生效；Nix 默认见 modules/system/multimedia.nix。
EOF
}

pw_settings() {
  pw-metadata -n settings 0 "$1" "$2" >/dev/null
}

show_status() {
  echo "PipeWire:"
  pw-metadata -n settings 2>/dev/null | sed -n "s/.*key:'\\([^']*\\)' value:'\\([^']*\\)'.*/  \\1=\\2/p" | grep '^  clock\.' || true
  echo "HDA power_save:"
  if [[ -r "$SYS_PS" ]]; then
    echo "  power_save=$(cat "$SYS_PS")  (0=关, >0=空闲秒数后休眠)"
    echo "  power_save_controller=$(cat "$SYS_PSC")"
  else
    echo "  (snd_hda_intel 未加载)"
  fi
  if command -v pactl >/dev/null; then
    echo "默认 sink:"
    pactl info 2>/dev/null | sed -n 's/^默认采样规格：/  /p;s/^默认音频入口：/  sink=/p'
  fi
}

set_rate() {
  local hz="$1"
  pw_settings clock.allowed-rates '[ 48000, 96000, 192000 ]'
  if [[ "$hz" == "0" ]]; then
    pw_settings clock.force-rate 0
    pw_settings clock.rate 48000
    echo "已取消强制采样率（允许 48/96/192 kHz，按流切换）"
  else
    pw_settings clock.rate "$hz"
    pw_settings clock.force-rate "$hz"
    echo "已强制图时钟 ${hz} Hz"
  fi
}

set_powersave() {
  local mode="$1"
  case "$mode" in
    off | on) ;;
    *)
      echo "audio-clock: powersave 只能是 on 或 off" >&2
      exit 2
      ;;
  esac
  if [[ -n "${AUDIO_HDA_POWERSAVE:-}" && -x "${AUDIO_HDA_POWERSAVE}" ]]; then
    /run/wrappers/bin/sudo "${AUDIO_HDA_POWERSAVE}" "$mode"
  elif [[ -w "$SYS_PS" ]]; then
    if [[ "$mode" == off ]]; then
      printf '0\n' >"$SYS_PS"
      printf 'N\n' >"$SYS_PSC"
    else
      printf '10\n' >"$SYS_PS"
      printf 'Y\n' >"$SYS_PSC"
    fi
  else
    echo "audio-clock: 需要 rebuild 安装 audio-hda-powersave，或手动 sudo tee 写 sysfs" >&2
    exit 1
  fi
  echo "HDA power_save=$(cat "$SYS_PS") power_save_controller=$(cat "$SYS_PSC")"
}

cmd="${1:-status}"
case "$cmd" in
  -h | --help | help)
    usage
    ;;
  status | "")
    show_status
    ;;
  auto)
    set_rate 0
    show_status
    ;;
  48 | 48000)
    set_rate 48000
    show_status
    ;;
  96 | 96000)
    set_rate 96000
    show_status
    ;;
  192 | 192000)
    set_rate 192000
    show_status
    ;;
  powersave)
    set_powersave "${2:-}"
    show_status
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
