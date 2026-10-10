# 云枢写死 /opt/apps/yunshu，且要在该目录里写配置和套接字。
# 同步服务把商店副本铺到 /opt，升级时保留 files/config。
{ config, lib, pkgs, ... }:

let
  graphical = config.modules.graphical;
  cfg = graphical.yunshu;
  pkg = pkgs.yunshu;
  # 装证书的脚本调用 PATH 里的 certutil。服务默认 PATH 不含系统 profile。
  # /usr 只读，不能把 certutil 链到 /usr/bin 或 /bin。nss.tools 自带 RUNPATH。
  certutil = pkgs.runCommand "yunshu-certutil" { } ''
    mkdir -p "$out/bin"
    ln -s "${pkgs.nss.tools}/bin/certutil" "$out/bin/certutil"
  '';
in
{
  options.modules.graphical.yunshu = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "安装云枢客户端并启动 daemon。仅在图形桌面启用时生效。";
    };
  };

  config = lib.mkIf (graphical.enable && cfg.enable) {
    environment.systemPackages = [ pkg ];

    systemd.tmpfiles.rules = [
      "d /opt/apps 0755 root root -"
      "d /var/log/yunshu 0755 root root -"
    ];

    systemd.services.yunshu-sync = {
      description = "把云枢铺到 /opt/apps/yunshu";
      wantedBy = [ "multi-user.target" ];
      before = [
        "yunshu-daemon.service"
        "yunshu-updater.service"
        "display-manager.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        set -euo pipefail
        src="${pkg.unwrapped}/opt/apps/yunshu"
        dest=/opt/apps/yunshu
        stamp="$dest/.nix-source"
        if [[ ! -f "$stamp" || "$(cat "$stamp")" != "$src" ]]; then
          saved="$(mktemp -d)"
          if [[ -d "$dest/files/config" ]]; then
            cp -a "$dest/files/config" "$saved/config"
          fi
          rm -rf "$dest"
          mkdir -p /opt/apps
          cp -a "$src" "$dest"
          chmod -R u+w "$dest"
          if [[ -d "$saved/config" ]]; then
            cp -a "$saved/config/." "$dest/files/config/"
          fi
          rm -rf "$saved"
          printf '%s\n' "$src" > "$stamp"
        fi
        mkdir -p \
          "$dest/files/config" \
          "$dest/files/tmp" \
          "$dest/files/socket" \
          "$dest/files/bak" \
          "$dest/files/logs"
        chmod 1777 "$dest/files/socket" "$dest/files/tmp"
        if [[ ! -s "$dest/files/config/.corp_code" ]]; then
          printf '%s' "${pkg.corpCode}" > "$dest/files/config/.corp_code"
        fi
        if [[ ! -s "$dest/files/config/private_ctl.conf" ]]; then
          printf '%s\n' "https://sp.eagleyun.cn/" > "$dest/files/config/private_ctl.conf"
        fi
      '';
    };

    systemd.services.yunshu-daemon = {
      description = "云枢";
      after = [
        "network-online.target"
        "yunshu-sync.service"
      ];
      wants = [ "network-online.target" ];
      requires = [ "yunshu-sync.service" ];
      wantedBy = [ "multi-user.target" ];
      # 准入和内网路由会调用 ip、nmcli。装证书的脚本调用的是 PATH 里的 certutil。
      # 服务默认 PATH 不含系统 profile。
      path = [
        "/run/current-system/sw"
        certutil
      ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkg}/bin/yunshu-daemon";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

    systemd.services.yunshu-updater = {
      description = "云枢更新";
      after = [
        "network-online.target"
        "yunshu-sync.service"
      ];
      wants = [ "network-online.target" ];
      requires = [ "yunshu-sync.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ "/run/current-system/sw" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkg}/bin/yunshu-updater";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
