{ lib, ... }:

{

  programs.bash = {
    completion.enable = true;
    promptInit =
      ''
        PROMPT_COLOR="1;31m"
        let $UID && PROMPT_COLOR="1;32m"

        if [ "$TERM" != "dumb" -o -n "$INSIDE_EMACS" ]; then
          if [ -n "$INSIDE_EMACS" -o "$TERM" == "eterm" -o "$TERM" == "eterm-color" ]; then
            # Emacs term mode doesn't support xterm title escape sequence (\e]0;)
            # PS1="\n\[\033[$PROMPT_COLOR\][\u@\h:\W]\\$\[\033[0m\] "
            # PS1="\n\[$(start_refresh_prompt_time)\]\[$(tput sgr0)\]\[\033[$PROMPT_COLOR\][\t \u@\h:\W]\\$\[$(tput sgr0)\] \[$(tput sgr0)\]"
            PS1="\n\[$(tput sgr0)\]\[\033[$PROMPT_COLOR\][\t \u@\h:\W]\\$\[$(tput sgr0)\] \[$(tput sgr0)\]"
          else
            # PS1="\n\[\033[$PROMPT_COLOR\][\[\e]0;\u@\h: \W\a\]\u@\h:\W]\\$\[\033[0m\] "
            # PS1="\n\[$(start_refresh_prompt_time)\]\[$(tput sgr0)\]\[\033[$PROMPT_COLOR\][\t \u@\h:\W]\\$\[$(tput sgr0)\] \[$(tput sgr0)\]"
            PS1="\n\[$(tput sgr0)\]\[\033[$PROMPT_COLOR\][\t \u@\h:\W]\\$\[$(tput sgr0)\] \[$(tput sgr0)\]"
          fi
          if test "$TERM" = "xterm"; then
            PS1="\[\033]2;\h:\u:\W\007\]$PS1"
          fi
          # PROMPT_COMMAND=stop_refresh_prompt_time
          # PS0=
          # PS2="\[$(stop_refresh_prompt_time)\]$PS2"
          # PS3="\[$(stop_refresh_prompt_time)\]$PS3"
          # PS4="\[$(stop_refresh_prompt_time)\]$PS4"
        fi
      '';

    shellAliases = { };
  };

  # environment.binsh = "${pkgs.bash}/bin/bash";
}
