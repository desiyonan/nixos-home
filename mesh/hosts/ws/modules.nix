# 按 host 启用 modules/ 下可复用模块（options.modules.<name>.enable）
# Development tools are on by default (options.modules.develop); e.g. modules.develop.rust.enable = false;
{ config, lib, pkgs, ... }:

{
  modules.network.enable = true;
  modules.network.enableIPv6 = false;
  modules.network.proxy.enable = true;

  modules.graphical.enable = true;
  modules.graphical.nvidia.enable = true;
  # HP ZBook Studio G5：Lite-On HP HD Camera（04ca:706d）。
  # 仅 video0=capture、video1=metadata，无独立 IR 节点；by-id 避免 videoN 漂移。
  # irEmitter.device 必须是内核名 video0（systemd After=dev-video0.device）。
  modules.graphical.howdy.devicePath =
    "/dev/v4l/by-id/usb-DHCNL019IBT8VB_HP_HD_Camera-video-index0";
  modules.graphical.howdy.irEmitter.device = "video0";
  secret-hub.legacyUsersPrefix = true;
  secret-hub.extraSecrets = [
    "programs"
    "account"
  ];
  modules.vlan.enable = true;

  modules.devops.enable = true;
  modules.devops.waydroid.enable = true;

  modules.game.enable = true;
}
