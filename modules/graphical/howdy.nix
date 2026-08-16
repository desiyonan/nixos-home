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
        # SDDM / kscreenlocker：识别成功后不要再等回车
        core.no_confirmation = true;
      };
    };

    services.linux-enable-ir-emitter = lib.mkIf cfg.irEmitter.enable {
      enable = true;
      device = irDevice;
    };

    environment.systemPackages = [ pkgs.v4l-utils ];

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
