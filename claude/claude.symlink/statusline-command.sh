#!/usr/bin/env bash
# ~/.claude/statusline-command.sh
# Claude Code status line: two-line colorful prompt-style display.
# Receives JSON from Claude Code via stdin.

# ---------------------------------------------------------------------------
# Color palette (ANSI escape codes)
# ---------------------------------------------------------------------------
ESC=$'\033'
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
DIM="${ESC}[2m"

# Foreground colors
FG_BLACK="${ESC}[30m"
FG_RED="${ESC}[31m"
FG_GREEN="${ESC}[32m"
FG_YELLOW="${ESC}[33m"
FG_BLUE="${ESC}[34m"
FG_MAGENTA="${ESC}[35m"
FG_CYAN="${ESC}[36m"
FG_WHITE="${ESC}[37m"
FG_BRIGHT_BLACK="${ESC}[90m"
FG_BRIGHT_RED="${ESC}[91m"
FG_BRIGHT_GREEN="${ESC}[92m"
FG_BRIGHT_YELLOW="${ESC}[93m"
FG_BRIGHT_BLUE="${ESC}[94m"
FG_BRIGHT_MAGENTA="${ESC}[95m"
FG_BRIGHT_CYAN="${ESC}[96m"
FG_BRIGHT_WHITE="${ESC}[97m"

# Rainbow palette (used for the context-usage bar)
RAINBOW=(
  "${ESC}[91m" # red
  "${ESC}[93m" # yellow
  "${ESC}[92m" # green
  "${ESC}[96m" # cyan
  "${ESC}[94m" # blue
  "${ESC}[95m" # magenta
)

# ---------------------------------------------------------------------------
# Read and parse JSON input
# ---------------------------------------------------------------------------
input=$(cat)

model_name=$(echo "$input" | jq -r '.model.display_name // "Unknown Model"')
session_id=$(echo "$input" | jq -r '.session_id // ""')
cwd=$(echo "$input" | jq -r '.cwd // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
remaining_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
block_resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
block_used_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
[ -n "$block_used_pct" ] && block_used_pct=$(printf "%.0f" "$block_used_pct")

# Effort level lives in ~/.claude/settings.json, not in the statusline JSON.
effort_level=$(jq -r '.effortLevel // empty' "$HOME/.claude/settings.json" 2>/dev/null)

# ---------------------------------------------------------------------------
# Memory: get RSS (in MB) of the claude process
# ---------------------------------------------------------------------------
# ps -o rss outputs kilobytes on macOS; divide by 1024 for MB.
claude_pid=$(pgrep -n -f "claude" 2>/dev/null | head -1)
mem_mb=""
if [ -n "$claude_pid" ]; then
  rss_kb=$(ps -o rss= -p "$claude_pid" 2>/dev/null | tr -d ' ')
  if [ -n "$rss_kb" ] && [ "$rss_kb" -gt 0 ] 2>/dev/null; then
    mem_mb=$((rss_kb / 1024))
  fi
fi

# ---------------------------------------------------------------------------
# Context window usage bar (20 chars wide, colorful gradient)
# ---------------------------------------------------------------------------
# Builds a filled/empty bar and colors it green → yellow → red as usage grows.
build_bar() {
  local pct="${1:-0}"
  local bar_width=20
  pct=$(printf "%.0f" "$pct" 2>/dev/null || echo "0")
  local filled=$((pct * bar_width / 100))
  [ "$filled" -gt "$bar_width" ] && filled=$bar_width
  local empty=$((bar_width - filled))

  # --- Smooth 20-step HSV rainbow (truecolor, 24-bit) ------------------------
  # Each cell has its own hue, stepped through 360° for a soft gradient.
  local rgb=(
    "255;0;0"    "255;77;0"   "255;153;0"  "255;230;0"
    "204;255;0"  "128;255;0"  "51;255;0"   "0;255;26"
    "0;255;102"  "0;255;179"  "0;255;255"  "0;179;255"
    "0;102;255"  "0;26;255"   "51;0;255"   "128;0;255"
    "204;0;255"  "255;0;230"  "255;0;153"  "255;0;77"
  )

  # --- Filled portion: braille block (⣿) with smooth rainbow gradient -------
  local bar=""
  local i
  for ((i = 0; i < filled; i++)); do
    bar="${bar}${ESC}[38;2;${rgb[$i]}m⣿"
  done

  # --- Empty portion: dim braille dots ---------------------------------------
  local empty_dim="${ESC}[38;2;68;68;78m"
  for ((i = 0; i < empty; i++)); do
    bar="${bar}${empty_dim}⣀"
  done
  bar="${bar}${RESET}"

  printf '%s' "${DIM}[${RESET}${bar}${DIM}]${RESET} ${FG_BRIGHT_BLACK}${pct}%%${RESET}"
}

# ---------------------------------------------------------------------------
# 5-hour usage block reset timer
# ---------------------------------------------------------------------------
# Formats the time remaining until the 5-hour usage block resets as e.g. "2h34m".
build_block_timer() {
  local resets_at="$1"
  local used_pct="$2"
  [ -z "$resets_at" ] && return
  local now=$(date +%s)
  local remaining=$(( resets_at - now ))
  [ "$remaining" -lt 0 ] && remaining=0
  local hours=$(( remaining / 3600 ))
  local minutes=$(( (remaining % 3600) / 60 ))
  local time_str
  if [ "$hours" -gt 0 ]; then
    time_str=$(printf '%dh%02dm' "$hours" "$minutes")
  else
    time_str=$(printf '%dm' "$minutes")
  fi
  # Color the timer by block usage %: green < 50, yellow < 80, red otherwise.
  local color="$FG_BRIGHT_GREEN"
  if [ -n "$used_pct" ]; then
    if [ "$used_pct" -ge 80 ]; then
      color="$FG_BRIGHT_RED"
    elif [ "$used_pct" -ge 50 ]; then
      color="$FG_BRIGHT_YELLOW"
    fi
    printf '%s' "${color}⏱ ${time_str} ${FG_BRIGHT_BLACK}(${used_pct}%%)${RESET}"
  else
    printf '%s' "${color}⏱ ${time_str}${RESET}"
  fi
}

# ---------------------------------------------------------------------------
# Git branch and stat (+added,-removed)
# ---------------------------------------------------------------------------
git_branch=""
git_stat=""
if git_dir=$(git -C "$cwd" rev-parse --git-dir --no-optional-locks 2>/dev/null | head -1); then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null ||
    git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  # numstat: sum insertions and deletions across all changed files
  numstat=$(git -C "$cwd" diff --numstat --no-optional-locks 2>/dev/null)
  if [ -n "$numstat" ]; then
    added=$(echo "$numstat" | awk '{s+=$1} END {print s+0}')
    removed=$(echo "$numstat" | awk '{s+=$2} END {print s+0}')
  else
    added=0
    removed=0
  fi
  git_stat=$(printf "${FG_BRIGHT_GREEN}+%d${RESET}${FG_BRIGHT_BLACK},${RESET}${FG_BRIGHT_RED}-%d${RESET}" "$added" "$removed")
fi

# ---------------------------------------------------------------------------
# Relative PWD (replace $HOME with ~)
# ---------------------------------------------------------------------------
rel_pwd="${cwd/#$HOME/\~}"

# ---------------------------------------------------------------------------
# Strip ANSI escape codes to measure visible string length
# ---------------------------------------------------------------------------
strip_ansi() {
  # Remove all ESC[ ... m sequences
  printf '%s' "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

visible_len() {
  local stripped
  stripped=$(strip_ansi "$1")
  echo "${#stripped}"
}

# ---------------------------------------------------------------------------
# Right-align a string on the terminal
# ---------------------------------------------------------------------------
# Returns a string padded with spaces on the left so it ends at column $COLUMNS.
right_pad() {
  local left_str="$1"  # already-rendered left side (with ANSI)
  local right_str="$2" # already-rendered right side (with ANSI)
  local term_width
  # stty reads from /dev/tty so it works even though stdin is a JSON pipe.
  term_width=$(stty size </dev/tty 2>/dev/null | awk '{print $2}')
  [ -z "$term_width" ] && term_width="${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}"
  # Claude Code statusline has a small right-edge margin; back off a couple
  # columns so wide right-aligned content doesn't wrap and eat line 2.
  term_width=$((term_width - 6))

  local left_len right_len pad
  left_len=$(visible_len "$left_str")
  right_len=$(visible_len "$right_str")
  pad=$((term_width - left_len - right_len))
  [ "$pad" -lt 1 ] && pad=1

  printf '%s%*s%s' "$left_str" "$pad" "" "$right_str"
}

# ---------------------------------------------------------------------------
# Assemble line 1
# ---------------------------------------------------------------------------
# Left: model | effort | memory
left1="${BOLD}${FG_BRIGHT_CYAN}${model_name}${RESET}"
if [ -n "$effort_level" ]; then
  # Color the effort level by intensity.
  case "$effort_level" in
    high)   effort_color="$FG_BRIGHT_RED" ;;
    medium) effort_color="$FG_BRIGHT_YELLOW" ;;
    low)    effort_color="$FG_BRIGHT_GREEN" ;;
    *)      effort_color="$FG_BRIGHT_WHITE" ;;
  esac
  left1="${left1} ${FG_BRIGHT_BLACK}|${RESET} ${effort_color}⚡${effort_level}${RESET}"
fi
if [ -n "$mem_mb" ]; then
  left1="${left1} ${FG_BRIGHT_BLACK}|${RESET} ${FG_BRIGHT_MAGENTA}${mem_mb}MB${RESET}"
fi

# Right: block reset timer | context bar
right1=""
if [ -n "$block_resets_at" ]; then
  right1=$(build_block_timer "$block_resets_at" "$block_used_pct")
fi
if [ -n "$used_pct" ]; then
  bar_str=$(build_bar "$used_pct")
  if [ -n "$right1" ]; then
    right1="${right1} ${FG_BRIGHT_BLACK}|${RESET} ${bar_str}"
  else
    right1="${bar_str}"
  fi
fi

# ---------------------------------------------------------------------------
# Assemble line 2
# ---------------------------------------------------------------------------
# Left: session ID (dimmed, truncated to 16 chars)
left2="${DIM}${FG_BRIGHT_BLACK}session:${RESET}${DIM}${FG_WHITE}${session_id}${RESET}"

# Right: branch (+x,-y) | relative PWD
separator="${FG_BRIGHT_BLACK}|${RESET}"
right2="${FG_BRIGHT_BLUE}${rel_pwd}${RESET}"
if [ -n "$git_branch" ]; then
  right2="${right2} ${separator} ${FG_BRIGHT_YELLOW}⎇ ${git_branch}${RESET}"
  if [ -n "$git_stat" ]; then
    right2="${right2} ${FG_BRIGHT_BLACK}(${RESET}${git_stat}${FG_BRIGHT_BLACK})${RESET}"
  fi
fi

# ---------------------------------------------------------------------------
# Print both lines using right_pad for alignment
# ---------------------------------------------------------------------------
printf '%s\n' "$(right_pad "$left1" "$right1")"
printf '%s\n' "$(right_pad "$left2" "$right2")"
