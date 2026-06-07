# Applied by modules/system/3x-ui/default.nix (preStart). Environment variables are set by Nix.
set -euo pipefail

yq() {
  command @yq@ -r "$@"
}

yaml_get() {
  local key="$1"
  [[ -n "${SETTINGS_FILE:-}" && -f "$SETTINGS_FILE" ]] || return 0
  [[ "$key" == .* ]] || key=".$key"
  yq "${key} // \"\"" "$SETTINGS_FILE"
}

yaml_get_bool() {
  [[ -n "${SETTINGS_FILE:-}" && -f "$SETTINGS_FILE" ]] || return 1
  local v
  v=$(yq "${1} // \"\"" "$SETTINGS_FILE")
  [[ "$v" == "true" ]]
}

# Nix override wins when non-empty; otherwise read from YAML.
effective() {
  local override="$1"
  local yaml_key="$2"
  if [[ -n "$override" ]]; then
    printf '%s' "$override"
  else
    yaml_get "$yaml_key"
  fi
}

read_credential() {
  local name="$1"
  local override="$2"
  local override_file="$3"
  local file_path value

  if [[ -n "$override_file" ]]; then
    cat "$override_file"
    return
  fi
  if [[ -n "$override" ]]; then
    printf '%s' "$override"
    return
  fi

  file_path=$(yaml_get "${name}File")
  if [[ -n "$file_path" ]]; then
    cat "$file_path"
    return
  fi

  yaml_get "$name"
}

export XUI_DB_FOLDER="@dataDir@"
export XUI_BIN_FOLDER="@dataDir@/bin"
export XUI_LOG_FOLDER="@dataDir@/logs"
ln -sf @xray@/bin/xray "@dataDir@/bin/xray-linux-amd64"

port=$(effective "${OVERRIDE_PORT:-}" ".port")
username=$(read_credential username "${OVERRIDE_USERNAME:-}" "${OVERRIDE_USERNAME_FILE:-}")
password=$(read_credential password "${OVERRIDE_PASSWORD:-}" "${OVERRIDE_PASSWORD_FILE:-}")
listenIP=$(effective "${OVERRIDE_LISTEN_IP:-}" ".listenIP")
webBasePath=$(effective "${OVERRIDE_WEB_BASE_PATH:-}" ".webBasePath")
webCert=$(effective "${OVERRIDE_WEB_CERT:-}" ".webCert")
webCertKey=$(effective "${OVERRIDE_WEB_CERT_KEY:-}" ".webCertKey")

tg_enable_override="${OVERRIDE_TG_ENABLE:-}"
tg_token=$(effective "${OVERRIDE_TG_TOKEN:-}" ".telegram.token")
tg_chat_id=$(effective "${OVERRIDE_TG_CHAT_ID:-}" ".telegram.chatId")
tg_runtime=$(effective "${OVERRIDE_TG_RUNTIME:-}" ".telegram.runtime")

setting_args=()
[[ -n "$port" ]] && setting_args+=(-port "$port")
if [[ -n "$username" || -n "$password" ]]; then
  [[ -n "$username" ]] && setting_args+=(-username "$username")
  [[ -n "$password" ]] && setting_args+=(-password "$password")
fi
[[ -n "$webBasePath" ]] && setting_args+=(-webBasePath "$webBasePath")
[[ -n "$listenIP" ]] && setting_args+=(-listenIP "$listenIP")

if ((${#setting_args[@]} > 0)); then
  @x3ui@/bin/3x-ui setting "${setting_args[@]}"
fi

if [[ -n "$webCert" || -n "$webCertKey" ]]; then
  @x3ui@/bin/3x-ui setting -webCert "$webCert" -webCertKey "$webCertKey"
fi

if [[ "${OVERRIDE_RESET_TWO_FACTOR:-}" == "true" ]] || yaml_get_bool ".resetTwoFactor"; then
  @x3ui@/bin/3x-ui setting -resetTwoFactor
fi

if [[ -n "$tg_token" || -n "$tg_chat_id" || -n "$tg_runtime" ]]; then
  tg_args=()
  [[ -n "$tg_token" ]] && tg_args+=(-tgbottoken "$tg_token")
  [[ -n "$tg_chat_id" ]] && tg_args+=(-tgbotchatid "$tg_chat_id")
  [[ -n "$tg_runtime" ]] && tg_args+=(-tgbotRuntime "$tg_runtime")
  @x3ui@/bin/3x-ui setting "${tg_args[@]}"
fi

tg_enable_yaml=$(yaml_get ".telegram.enable")
if [[ "$tg_enable_override" == "true" ]] || {
  [[ -z "$tg_enable_override" ]] && [[ "$tg_enable_yaml" == "true" ]]
}; then
  @x3ui@/bin/3x-ui setting -enabletgbot
fi
