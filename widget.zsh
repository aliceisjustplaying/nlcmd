# Natural language to shell command widget
# Usage: source this file, then type natural language and press Ctrl+G

typeset -g _NLCMD_SCRIPT_DIR="${0:A:h}"

nlcmd() {
  local input="$BUFFER"
  local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

  # Use a FIFO for streaming
  local fifo=$(mktemp -u)
  mkfifo "$fifo"

  # Start CLI in background, write to FIFO
  ( echo "$input" | bun "$_NLCMD_SCRIPT_DIR/cli.ts" 2>/dev/null > "$fifo" ) &!
  local pid=$!

  # Open FIFO for reading (non-blocking setup)
  exec {fd}<"$fifo"

  local char i=0 first=1

  while true; do
    if read -r -k 1 -u $fd -t 0.05 char 2>/dev/null; then
      if [[ $first -eq 1 ]]; then
        BUFFER=""
        first=0
      fi
      BUFFER+="$char"
      CURSOR=${#BUFFER}
      zle redisplay
    else
      local ret=$?
      # Check if process is still running
      if ! kill -0 $pid 2>/dev/null; then
        # Process done, drain remaining
        while read -r -k 1 -u $fd char 2>/dev/null; do
          if [[ $first -eq 1 ]]; then
            BUFFER=""
            first=0
          fi
          BUFFER+="$char"
        done
        break
      fi
      # Still waiting - show spinner
      if [[ $first -eq 1 ]]; then
        BUFFER="$input ${spin:$((i % 10)):1}"
        CURSOR=${#BUFFER}
        zle redisplay
        ((i++))
      fi
    fi
  done

  exec {fd}<&-
  rm -f "$fifo"
}

zle -N nlcmd
bindkey '^G' nlcmd
