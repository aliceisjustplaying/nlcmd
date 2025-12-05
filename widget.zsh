# Natural language to shell command widget
# Usage: source this file, then type natural language and press Ctrl+G

typeset -g _NLCMD_SCRIPT_DIR="${0:A:h}"

nlcmd() {
  local input="$BUFFER"
  local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

  # Start CLI in background, write to temp file
  local tmpfile=$(mktemp)
  ( echo "$input" | bun "$_NLCMD_SCRIPT_DIR/cli.ts" 2>/dev/null > "$tmpfile" ) &!

  local pid=$!

  # Animate spinner while waiting
  local i=0
  while kill -0 $pid 2>/dev/null; do
    BUFFER="$input ${spin:$((i % 10)):1}"
    CURSOR=${#BUFFER}
    zle redisplay
    sleep 0.05
    ((i++))
  done

  BUFFER="$(cat "$tmpfile")"
  CURSOR=${#BUFFER}
  rm -f "$tmpfile"
  zle redisplay
}

zle -N nlcmd
bindkey '^G' nlcmd
