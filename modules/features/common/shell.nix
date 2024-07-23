{ config, pkgs, ... }:

{

  programs.bash = {
    enableCompletion = true;
    promptInit =
      ''
        PROMPT_COLOR="1;31m"
        let $UID && PROMPT_COLOR="1;32m"
        update_prompt_time() {
            tput sc;
            echo -ne "\e[$(tput sgr0 && tput hpa 1)\033[$PROMPT_COLOR$(date "+%T")\e[$(tput sgr0)";
            # echo -ne "\e[$(tput sgr0 && tput hpa 1)$(date "+%T")\e[$(tput sgr0)";
            tput rc;
        }

        init_session_upt() {
            session_scope="/tmp/shell-$$"
            mkdir -p $session_scope
            upt_pipe=$session_scope/upt.pipe
            upt_pid=$session_scope/upt.pid
            echo "scope=$session_scope"

            if [[ ! -p $upt_pipe ]]; then
                mkfifo $upt_pipe
            fi
            trap "rm -rf $session_scope" EXIT

            (
                while true
                do
                    sleep 5
                    update_prompt_time
                done &
                echo $! > $upt_pid
            )
            cat $upt_pid

            trap "cat $upt_pid | xargs kill -9 " EXIT
            trap "rm -rf $session_scope;" EXIT
        }

        start_refresh_prompt_time() {
          UPT_ID=$(cat $session_scope/upt.pid)
          if ps -p $UPT_ID > /dev/null 2>&1;
          then
              kill -SIGCONT $UPT_ID
          fi
        }

        stop_refresh_prompt_time() {
          UPT_ID=$(cat $session_scope/upt.pid)
          if ps -p $UPT_ID > /dev/null 2>&1;
          then
              kill -SIGTSTP $UPT_ID
          fi
        }

        # init_session_upt

        if [ "$TERM" != "dumb" -o -n "$INSIDE_EMACS" ]; then
          PROMPT_COLOR="1;31m"
          let $UID && PROMPT_COLOR="1;32m"
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
    interactiveShellInit = ''eval "$(direnv hook bash)"'';
  };

  # environment.binsh = "${pkgs.bash}/bin/bash";
}
