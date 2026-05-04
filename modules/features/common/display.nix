{ config, pkgs, lib, ... }:

{
  # GTK 应用在 Plasma 下从 GSettings 读图标主题；未启用时常见「几乎全部」缺图标或齿轮。
  #programs.dconf.enable = true;

  programs.xwayland.enable = lib.mkForce false;
  services = {
    desktopManager={
      plasma6={
        enable = true;
      };
    };
    displayManager= {
      sddm={
        enable=true;
        wayland.enable=true;
      };
      defaultSession = "plasma";
    };
    xserver = {
      # 关闭 Xorg；SDDM + Plasma 仍可通过 Wayland 启动（NVIDIA 驱动由 hardware.nvidia / videoDrivers 等路径加载）
      enable = false;
    };
  };


  environment.systemPackages = [
    # ... other packages
    pkgs.plasma-panel-colorizer
    # 全局图标兜底：hicolor 为 Freedesktop 默认回退；Adwaita 供 GTK；Breeze 与 Plasma 菜单一致
    pkgs.hicolor-icon-theme
  ];

  # environment = {
  #   systemPackages = with pkgs; [
  #     qt5ct
  #     # qt5.full
  #     qt6.full
  #   ];
  #   variables = {
  #     MOZ_ENABLE_WAYLAND="1";
  #   };
  #   sessionVariables = {
  #     MOZ_ENABLE_WAYLAND="1";
  #   };
  # };

}
