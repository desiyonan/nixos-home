# 全主机启用 kmscon：TTY 用 TrueType 渲染，支持中文（替代内核 VT 位图字体）
# 进入 kmscon 交互 shell 时自动 exec uim-fep（overlay 已 wrap；桌面仍用 fcitx5）
# uim 点文件：mesh/dotfs/uim/
{ pkgs, ... }:

let
  uimDot = pkgs.mesh.dotfs.uim;

  # 注意：
  # 1) /etc/set-environment 会注入 pipewire-jack 的 LD_LIBRARY_PATH，
  #    触发 uim#207（make_loaded_str SIGSEGV）；exec 后会话直接结束，表现为「无法登录」。
  # 2) uim-fep 的 -c 是 reverse cursor，不是「启动 shell」；启动 shell 用默认或 -e。
  # 3) HM 只管普通用户；root 无 HM，需 activation 写 /root，且启动时强制 -u py。
  autoUim = ''
    case "$-" in *i*)
      if [ -z "''${UIM_FEP_PID:-}" ] && command -v uim-fep >/dev/null 2>&1; then
        _uim_under_kmscon() {
          _p=$$
          while [ "$_p" -gt 1 ]; do
            _c=$(ps -o comm= -p "$_p" 2>/dev/null | tr -d ' ')
            case "$_c" in
              kmscon) return 0 ;;
            esac
            _p=$(ps -o ppid= -p "$_p" 2>/dev/null | tr -d ' ')
            [ -n "$_p" ] || break
          done
          return 1
        }
        if _uim_under_kmscon; then
          export LANG="''${LANG:-zh_CN.UTF-8}"
          export TERM="''${TERM:-xterm-256color}"
          unset -f _uim_under_kmscon
          # -u py：root 等无 HM 用户也强制拼音；env -u：避开 LD_LIBRARY_PATH 崩溃
          exec env -u LD_LIBRARY_PATH UIM_FEP=py uim-fep -u py -s lastline
        fi
        unset -f _uim_under_kmscon
      fi
      ;;
    esac
  '';
in
{
  services.kmscon = {
    enable = true;
    hwRender = false;
    fonts = [
      {
        name = "Sarasa Mono SC";
        package = pkgs.sarasa-gothic;
      }
      {
        name = "Noto Sans Mono CJK SC";
        package = pkgs.noto-fonts-cjk-sans;
      }
    ];
    extraConfig = ''
      font-size=14
      xkb-layout=us
    '';
  };

  environment.systemPackages = [ pkgs.uim ];
  environment.interactiveShellInit = autoUim;
  # 勿设 environment.variables.UIM_FEP：会进 Plasma/Cursor 等桌面进程，
  # libuim 初始化时尝试写 ~/.uim.d/customs，HM 只读 symlink 时弹「无法写入」。
  # 默认引擎由 overlays/uim.nix 的 wrap --set-default UIM_FEP=py，以及下方 -u py 保证。

  # root 无 HM：与 HM 用户同一套 mesh/dotfs/uim 配置
  system.activationScripts.uim-root-config = {
    text = ''
      install -d -m 700 /root/.uim.d/customs
      install -m 600 ${uimDot.dotUim} /root/.uim
      install -m 600 ${uimDot.customGlobal} /root/.uim.d/customs/custom-global.scm
      install -m 600 ${uimDot.customKeys1} /root/.uim.d/customs/custom-global-keys1.scm
    '';
  };

  # HM：复制为可写普通文件（勿用 home.file→store 只读 symlink，uim/Cursor 会报无法写入）
  home-manager.sharedModules = [
    (
      { lib, ... }:
      {
        # 须在 linkGeneration 之后：否则旧 home.file 清理/链接会覆盖刚复制的可写文件
        home.activation.uimDotfs = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
          install -d -m 700 "$HOME/.uim.d/customs"
          install -m 600 ${uimDot.dotUim} "$HOME/.uim"
          install -m 600 ${uimDot.customGlobal} "$HOME/.uim.d/customs/custom-global.scm"
          install -m 600 ${uimDot.customKeys1} "$HOME/.uim.d/customs/custom-global-keys1.scm"
        '';
      }
    )
  ];
}
