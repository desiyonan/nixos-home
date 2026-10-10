# 交互提示符只在这里定义。programs.bash.promptInit 与 appimage-run 的 FHS
# profile 都引用这份脚本，避免登录 shell 落回 appimage-run-fhsenv 的默认 PS1。
''
  PROMPT_COLOR="1;31m"
  let $UID && PROMPT_COLOR="1;32m"

  if [ "$TERM" != "dumb" -o -n "$INSIDE_EMACS" ]; then
    # Emacs term 不支持 xterm 标题转义，主提示符两边用同一条。
    PS1="\n\[$(tput sgr0)\]\[\033[$PROMPT_COLOR\][\t \u@\h:\W]\\$\[$(tput sgr0)\] \[$(tput sgr0)\]"
    if test "$TERM" = "xterm"; then
      PS1="\[\033]2;\h:\u:\W\007\]$PS1"
    fi
  fi
''
