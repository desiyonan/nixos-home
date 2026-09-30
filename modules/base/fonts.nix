{ pkgs, config, lib, ... }:

let
  # 与系统 /etc/fonts/local.conf 同内容；HM 复制为可写文件（Cursor 等会尝试写 fonts.conf）
  userFontsConf = pkgs.writeText "user-fonts.conf" config.fonts.fontconfig.localConf;

  # WPS/Word 中文默认宋体、黑体、楷体只有 Regular。90-synthetic.conf 会 embolden，
  # FreeType 描边后 CJK 笔画糊成一团黑。粗体改走 Noto CJK 真 Bold。
  fcBoldAlias =
    to: froms:
    lib.concatMapStrings (from: ''
          <match target="pattern">
            <test name="family"><string>${from}</string></test>
            <test name="weight" compare="more"><const>medium</const></test>
            <edit name="family" mode="assign" binding="strong">
              <string>${to}</string>
            </edit>
          </match>
    '') froms;

  fcAlias =
    to: froms:
    lib.concatMapStrings (from: ''
          <match target="pattern">
            <test name="family"><string>${from}</string></test>
            <edit name="family" mode="assign" binding="strong">
              <string>${to}</string>
            </edit>
          </match>
    '') froms;

  # 无独立 Bold 的 CJK；须排在 90-synthetic.conf 之后，否则 faux-bold 会被重新打开
  cjkNoFauxBoldFamilies = [
    "宋体"
    "SimSun"
    "新宋体"
    "NSimSun"
    "黑体"
    "SimHei"
    "楷体"
    "KaiTi"
    "楷体_GB2312"
    "KaiTi_GB2312"
    "文泉驿正黑"
    "WenQuanYi Zen Hei"
    "文泉驿微米黑"
    "WenQuanYi Micro Hei"
  ];
in
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

          <!-- WPS：宋体/黑体/楷体无 Bold，faux-bold 一团黑 → Noto CJK 真 Bold -->
    ${fcBoldAlias "Noto Serif CJK SC" [
      "宋体"
      "SimSun"
      "新宋体"
      "NSimSun"
      "楷体"
      "KaiTi"
      "楷体_GB2312"
      "KaiTi_GB2312"
    ]}
    ${fcBoldAlias "Noto Sans CJK SC" [
      "黑体"
      "SimHei"
    ]}
          <!-- 系统无仿宋 TTF；WPS/Word 常用名全部转到 Noto Serif -->
    ${fcAlias "Noto Serif CJK SC" [
      "仿宋"
      "FangSong"
      "仿宋_GB2312"
      "FangSong_GB2312"
    ]}
        </fontconfig>
      '';

      # 51-local.conf 早于 90-synthetic.conf；关 embolden 必须用更大序号。
      # 不能用 environment.etc."fonts/conf.d/..."：NixOS 已把 /etc/fonts 整树
      # 指到 fontconfig-etc，再往 conf.d 里 ln 会 Permission denied。
      confPackages = [
        (pkgs.writeTextFile {
          name = "cjk-no-faux-bold";
          destination = "/etc/fonts/conf.d/91-cjk-no-faux-bold.conf";
          text = ''
            <?xml version="1.0"?>
            <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
            <fontconfig>
            ${lib.concatMapStrings (f: ''
              <match target="font">
                <test name="family"><string>${f}</string></test>
                <edit name="embolden" mode="assign"><bool>false</bool></edit>
              </match>
            '') cjkNoFauxBoldFamilies}
            </fontconfig>
          '';
        })
      ];
    };
  };

  # Steam 需要用户级 fonts.conf（https://github.com/ValveSoftware/steam-for-linux/issues/10422）
  # 勿用 xdg.configFile→store 只读 symlink：Cursor 启动会尝试写入并弹窗。
  # 系统已管 fontconfig；关掉 HM 自带 conf.d，避免再堆只读链接。
  home-manager.sharedModules = [
    (
      { lib, ... }:
      {
        fonts.fontconfig.enable = false;
        home.activation.fontconfigWritable = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
          install -d -m 755 "$HOME/.config/fontconfig"
          install -m 644 ${userFontsConf} "$HOME/.config/fontconfig/fonts.conf"
        '';
      }
    )
  ];
}