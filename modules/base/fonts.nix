{ pkgs, ... }:

{
  fonts = {
    fontDir.enable = true;

    packages = with pkgs; [
      # 编程（西文）；中文等宽仍回退到 Sarasa Mono SC
      jetbrains-mono
      nerd-fonts.inconsolata
      inconsolata
      dejavu_fonts
      dejavu_fontsEnv

      # Linux 主用：UI + 编程等宽（中西文同宽）
      sarasa-gothic

      # 缺字兜底（不当默认）
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      wqy_microhei
      wqy_zenhei

      # Wine / Steam CEF：微软族名 TTF
      corefonts
      vista-fonts
      vista-fonts-cht
      vista-fonts-chs
    ];

    fontconfig = {
      enable = true;
      allowType1 = true;
      allowBitmaps = true;
      cache32Bit = true;

      defaultFonts = {
        sansSerif = [
          "Sarasa UI SC"
          "Microsoft YaHei"
          "Noto Sans CJK SC"
          "WenQuanYi Zen Hei"
        ];
        serif = [
          "Sarasa UI SC"
          "Noto Serif CJK SC"
          "WenQuanYi Zen Hei"
        ];
        monospace = [
          "Sarasa Mono SC"
          "Noto Sans Mono CJK SC"
          "WenQuanYi Zen Hei"
        ];
        emoji = [ "Noto Color Emoji" ];
      };

      # 系统唯一方案源。Steam 用户配置符号链接到此文件。
      # 内含 include：Steam 不读 /etc/fonts 整树时也能拉到字体目录与 defaultFonts。
      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          <include ignore_missing="yes">/etc/fonts/conf.d/00-nixos-cache.conf</include>
          <include ignore_missing="yes">/etc/fonts/conf.d/52-nixos-default-fonts.conf</include>

          <!-- 编程等宽族名 → Sarasa Mono -->
          <match target="pattern">
            <test name="family"><string>Droid Sans Mono</string></test>
            <edit name="family" mode="assign" binding="strong">
              <string>Sarasa Mono SC</string>
            </edit>
          </match>
          <match target="pattern">
            <test name="family"><string>Consolas</string></test>
            <edit name="family" mode="assign" binding="strong">
              <string>Sarasa Mono SC</string>
            </edit>
          </match>
          <match target="pattern">
            <test name="family"><string>Courier New</string></test>
            <edit name="family" mode="assign" binding="strong">
              <string>Sarasa Mono SC</string>
            </edit>
          </match>

          <!-- Wine UI → 微软雅黑 -->
          <match target="pattern">
            <test name="family"><string>Segoe UI</string></test>
            <edit name="family" mode="assign" binding="strong">
              <string>Microsoft YaHei</string>
            </edit>
          </match>
          <match target="pattern">
            <test name="family"><string>Tahoma</string></test>
            <edit name="family" mode="assign" binding="strong">
              <string>Microsoft YaHei</string>
            </edit>
          </match>
          <match target="pattern">
            <test name="family"><string>MS Shell Dlg</string></test>
            <edit name="family" mode="assign" binding="strong">
              <string>Microsoft YaHei</string>
            </edit>
          </match>
          <match target="pattern">
            <test name="family"><string>MS Shell Dlg 2</string></test>
            <edit name="family" mode="assign" binding="strong">
              <string>Microsoft YaHei</string>
            </edit>
          </match>
        </fontconfig>
      '';
    };
  };

  # Steam 只读用户级配置：直接链到系统 local.conf，不维护第二份内容
  # https://github.com/ValveSoftware/steam-for-linux/issues/10422
  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        xdg.configFile."fontconfig/fonts.conf" = {
          source = config.lib.file.mkOutOfStoreSymlink "/etc/fonts/local.conf";
          force = true;
        };
      }
    )
  ];
}