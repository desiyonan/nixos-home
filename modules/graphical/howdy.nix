# 仅随图形桌面启用；字符界面 / VPS 主机（graphical.enable = false）不会加载
{ config, lib, pkgs, ... }:

let
  graphical = config.modules.graphical;
  cfg = graphical.howdy;
  irDevice =
    if cfg.irEmitter.device != null then
      cfg.irEmitter.device
    else
      lib.removePrefix "/dev/" cfg.devicePath;
in
{
  options.modules.graphical.howdy = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Howdy facial authentication for the graphical desktop
        (SDDM / Plasma lock / polkit). Ignored unless modules.graphical.enable.
      '';
    };

    control = lib.mkOption {
      type = lib.types.str;
      default = "sufficient";
      description = ''
        PAM control flag for Howdy.
        `sufficient`: face or password (Windows Hello-like).
        `required`: face as a second factor.
      '';
    };

    devicePath = lib.mkOption {
      type = lib.types.str;
      default = "/dev/video2";
      description = "IR / RGB camera device used by Howdy.";
    };

    irEmitter = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Enable linux-enable-ir-emitter for IR cameras.
          After switch: `sudo linux-enable-ir-emitter configure`.
        '';
      };

      device = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          Kernel video node without `/dev/` (e.g. `video0`).
          Used as systemd `After=dev-<name>.device`.
          Must be `videoN`, not a by-id/by-path basename.
          `null` derives it from `devicePath` (only works for `/dev/videoN`).
        '';
      };
    };
  };

  config = lib.mkIf (graphical.enable && cfg.enable) {
    services.howdy = {
      enable = true;
      control = cfg.control;
      settings = {
        video.device_path = cfg.devicePath;
        # 识别成功后不自动注入 Enter，也不在 PAM 层强制结束密码提示；
        # 由用户手动提交当前认证界面，避免 native 路径遗留 TTY 的 -echo 状态。
        core.no_confirmation = true;
        core.workaround = "off";
      };
    };

    services.linux-enable-ir-emitter = lib.mkIf cfg.irEmitter.enable {
      enable = true;
      device = irDevice;
    };

    environment.systemPackages = [
      pkgs.v4l-utils
      pkgs.pinentry-howdy
    ];

    # 缓存时间不改。agent 只有在失效后才会来要口令；已登记 keygrip 先扫脸，
    # 再从已解开的 org.freedesktop.secrets 取出。比对由 root 套接字执行，不走 sudo。
    # root 使用自己的 Secret Service，不降权到图形用户。
    programs.gnupg.agent.pinentryPackage = pkgs.pinentry-howdy;
    systemd.packages = [ pkgs.pinentry-howdy ];
    systemd.sockets.pinentry-howdy.wantedBy = [ "sockets.target" ];
    systemd.services.pinentry-howdy-secrets.wantedBy = [ "multi-user.target" ];

    # SDDM greeter 默认不在 video 组，登录界面无法打开摄像头
    users.users.sddm.extraGroups = [ "video" ];

    # howdy add writes models here; meson path is not created by the NixOS module
    systemd.tmpfiles.rules = [
      "d /var/lib/howdy 0755 root root -"
      "d /var/lib/howdy/models 0755 root root -"
    ];

    # polkit 127 sandboxes polkit-agent-helper; Howdy needs the camera
    systemd.services."polkit-agent-helper@" = lib.mkIf config.security.polkit.enable {
      serviceConfig = {
        PrivateDevices = "no";
        DeviceAllow = [ "char-video4linux rw" ];
      };
    };
  };
}
