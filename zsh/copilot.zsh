#!/usr/bin/env zsh

# AI-powered CLI integration for zsh using Claude
# Optimized version with performance improvements and enhanced context

# ============================================================================
# CONFIGURATION
# ============================================================================

# Default key binding - Ctrl+Z
(( ! ${+ZSH_CLAUDE_KEY} )) &&
    typeset -g ZSH_CLAUDE_KEY='^z'

# Context always enabled by default, but configurable
(( ! ${+ZSH_CLAUDE_SEND_CONTEXT} )) &&
    typeset -g ZSH_CLAUDE_SEND_CONTEXT=true

# Debug mode
(( ! ${+ZSH_CLAUDE_DEBUG} )) &&
    typeset -g ZSH_CLAUDE_DEBUG=false

# Model (can override, but default to haiku for speed)
(( ! ${+ZSH_CLAUDE_MODEL} )) &&
    typeset -g ZSH_CLAUDE_MODEL=haiku

# Backward compatibility with old variable names
(( ${+ZSH_COPILOT_KEY} )) && ZSH_CLAUDE_KEY="$ZSH_COPILOT_KEY"
(( ${+ZSH_COPILOT_SEND_CONTEXT} )) && ZSH_CLAUDE_SEND_CONTEXT="$ZSH_COPILOT_SEND_CONTEXT"
(( ${+ZSH_COPILOT_DEBUG} )) && ZSH_CLAUDE_DEBUG="$ZSH_COPILOT_DEBUG"
(( ${+ZSH_COPILOT_LLM_MODEL} )) && ZSH_CLAUDE_MODEL="$ZSH_COPILOT_LLM_MODEL"


# ============================================================================
# SYSTEM PROMPT
# ============================================================================

# Concise system prompt for optimal performance
if [[ -z "$ZSH_CLAUDE_SYSTEM_PROMPT" ]]; then
read -r -d '' ZSH_CLAUDE_SYSTEM_PROMPT <<- EOM
You are a shell command autocompleter. Return ONLY ONE LINE starting with + or =.
Rules:
1. If completing existing input: start with +
2. If suggesting new command: start with =
3. NEVER explain or add commentary
4. NEVER use newlines
5. Your entire response must be: [+|=][command]

Examples:
Input: "list files" → =ls
Input: "cd /tm" → +p
Input: "git com" → +mit
EOM
fi

# Backward compatibility
(( ${+ZSH_COPILOT_SYSTEM_PROMPT} )) && ZSH_CLAUDE_SYSTEM_PROMPT="$ZSH_COPILOT_SYSTEM_PROMPT"

if [[ "$ZSH_CLAUDE_DEBUG" == 'true' ]]; then
    touch /tmp/zsh-claude.log
fi

# ============================================================================
# CONTEXT BUILDING
# ============================================================================

# Builds minimal context for speed
# Returns only essential context
function _build_context() {
    local input="$1"
    local context_info=""

    if [[ "$ZSH_CLAUDE_SEND_CONTEXT" != 'true' ]]; then
        echo ""
        return
    fi

    # Minimal context - just pwd and git branch if available
    context_info="Dir: $(basename $(pwd))."

    # Git branch only (no status for speed)
    local git_branch=$(git branch --show-current 2>/dev/null)
    if [[ -n "$git_branch" ]]; then
        context_info="$context_info Git: $git_branch."
    fi

    echo "$context_info"
}

# ============================================================================
# FETCH SUGGESTION FROM CLAUDE
# ============================================================================

# Fetches a command suggestion from Claude CLI using optimized flags
function _fetch_claude_suggestion() {
    local input="$1"
    local context="$2"

    # Build a single combined prompt (Claude Code's system prompt overrides --system-prompt)
    # So we put everything in the user message with VERY forceful instructions
    local combined_prompt="SHELL AUTOCOMPLETE MODE. Reply with EXACTLY ONE LINE.
Rules: If completing: +rest | If new command: =command | NO explanations | NO newlines
Example: 'cd /tm' → '+p' | 'list files' → '=ls'

$context

Complete: $input

REPLY FORMAT: [+|=][command]"

    # Call Claude with optimized flags for performance:
    # --print: non-interactive output mode
    # --output-format text: clean output without usage stats
    # --tools "": disable all tools for speed
    local response=$(claude --print \
        --model "$ZSH_CLAUDE_MODEL" \
        --tools "" \
        --output-format text \
        "$combined_prompt" 2>&1)
    local response_code=$?

    if [[ "$ZSH_CLAUDE_DEBUG" == 'true' ]]; then
        echo "{\"date\":\"$(date)\",\"log\":\"Called Claude CLI\",\"model\":\"$ZSH_CLAUDE_MODEL\",\"input\":\"$input\",\"response\":\"$response\",\"response_code\":\"$response_code\"}" >> /tmp/zsh-claude.log
    fi

    if [[ $response_code -ne 0 ]]; then
        echo "Error fetching suggestions from Claude CLI." > /tmp/.zsh_claude_error
        return 1
    fi

    # Extract only the line starting with + or = (in case Claude adds explanations)
    local message=$(echo "$response" | grep -E '^[+=]' | head -1 | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')

    # Fallback: if no line starts with +/=, take the last non-empty line
    if [[ -z "$message" ]]; then
        message=$(echo "$response" | grep -v '^\s*$' | tail -1 | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
    fi

    if [[ "$ZSH_CLAUDE_DEBUG" == 'true' ]]; then
        echo "{\"date\":\"$(date)\",\"log\":\"Extracted message\",\"message\":\"$message\",\"full_response\":\"$response\"}" >> /tmp/zsh-claude.log
    fi

    echo "$message" > /tmp/zsh_claude_suggestion || return 1
}

# ============================================================================
# LOADING ANIMATION
# ============================================================================

# Shows a loading animation while waiting for Claude
function _show_loading_animation() {
    local pid=$1
    local interval=0.1
    local animation_chars=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local i=1

    cleanup() {
        kill $pid 2>/dev/null
        echo -ne "\e[?25h"
    }
    trap cleanup SIGINT

    while kill -0 $pid 2>/dev/null; do
        # Display current animation frame
        zle -R "${animation_chars[i]}"

        # Update index, make sure it starts at 1
        i=$(( (i + 1) % ${#animation_chars[@]} ))

        if [[ $i -eq 0 ]]; then
            i=1
        fi

        sleep $interval
    done

    echo -ne "\e[?25h"
    trap - SIGINT
}

# ============================================================================
# MAIN SUGGESTION FUNCTION
# ============================================================================

# Main function that handles the suggestion workflow
function _suggest_claude_ai() {
    # Check for the Claude CLI lazily, at keypress time, so PATH is fully set up
    if ! command -v claude &> /dev/null; then
        zle -M "Claude CLI not found on PATH. Install Claude Code: https://claude.com/claude-code"
        return 1
    fi

    ##### Get input
    rm -f /tmp/zsh_claude_suggestion /tmp/.zsh_claude_error
    local input=$(echo "${BUFFER:0:$CURSOR}" | tr '\n' ';')
    input=$(echo "$input" | sed 's/"/\\"/g')

    # Clear any existing autosuggestions
    if (( ${+functions[_zsh_autosuggest_clear]} )); then
        _zsh_autosuggest_clear
    fi

    # Build context based on input
    local context_info=$(_build_context "$input")

    if [[ "$ZSH_CLAUDE_DEBUG" == 'true' ]]; then
        echo "{\"date\":\"$(date)\",\"log\":\"Built context\",\"input\":\"$input\",\"context\":\"$context_info\"}" >> /tmp/zsh-claude.log
    fi

    ##### Fetch message
    # Suppress job control messages
    setopt local_options no_notify no_monitor
    _fetch_claude_suggestion "$input" "$context_info" &
    local pid=$!

    _show_loading_animation $pid
    wait $pid
    local response_code=$?

    if [[ "$ZSH_CLAUDE_DEBUG" == 'true' ]]; then
        echo "{\"date\":\"$(date)\",\"log\":\"Fetched message\",\"input\":\"$input\",\"response_code\":\"$response_code\"}" >> /tmp/zsh-claude.log
    fi

    if [[ ! -f /tmp/zsh_claude_suggestion ]]; then
        if (( ${+functions[_zsh_autosuggest_clear]} )); then
            _zsh_autosuggest_clear
        fi
        zle -M "$(cat /tmp/.zsh_claude_error 2>/dev/null || echo 'No suggestion available at this time. Please try again later.')"
        return 1
    fi

    local message=$(cat /tmp/zsh_claude_suggestion)

    ##### Process response
    local first_char=${message:0:1}
    local suggestion=${message:1:${#message}}

    if [[ "$ZSH_CLAUDE_DEBUG" == 'true' ]]; then
        echo "{\"date\":\"$(date)\",\"log\":\"Suggestion extracted\",\"input\":\"$input\",\"first_char\":\"$first_char\",\"suggestion\":\"$suggestion\"}" >> /tmp/zsh-claude.log
    fi

    ##### Show the suggestion to the user
    if [[ "$first_char" == '=' ]]; then
        # Reset user input and insert new command
        BUFFER="$suggestion"
        CURSOR=${#BUFFER}
    elif [[ "$first_char" == '+' ]]; then
        # Append completion to current buffer
        if (( ${+functions[_zsh_autosuggest_suggest]} )); then
            _zsh_autosuggest_suggest "$suggestion"
        else
            # Fallback if zsh-autosuggestions not available
            BUFFER="${BUFFER}${suggestion}"
            CURSOR=${#BUFFER}
        fi
    else
        # If response doesn't have proper prefix, just append it
        BUFFER="${BUFFER}${message}"
        CURSOR=${#BUFFER}
    fi

    zle redisplay
}

# ============================================================================
# INFO FUNCTION
# ============================================================================

# Displays configuration information
function zsh-claude() {
    echo "ZSH Claude integration is now active. Press $ZSH_CLAUDE_KEY to get suggestions."
    echo ""
    echo "Features:"
    echo "    - Optimized for speed with minimal context"
    echo "    - Claude CLI with --print and --output-format text flags"
    echo "    - Tools disabled for faster responses"
    echo ""
    echo "Configurations:"
    echo "    - ZSH_CLAUDE_KEY: Key to press for suggestions (default: ^z, value: $ZSH_CLAUDE_KEY)"
    echo "    - ZSH_CLAUDE_MODEL: Which model to use (default: haiku, value: $ZSH_CLAUDE_MODEL)"
    echo "    - ZSH_CLAUDE_SEND_CONTEXT: Send minimal context (default: true, value: $ZSH_CLAUDE_SEND_CONTEXT)"
    echo "    - ZSH_CLAUDE_DEBUG: Enable debug logging to /tmp/zsh-claude.log (default: false, value: $ZSH_CLAUDE_DEBUG)"
    echo ""
    echo "Context includes (minimal for speed):"
    echo "    - Current directory basename"
    echo "    - Git branch (if in git repo)"
}

# Backward compatibility function
function zsh-copilot() {
    echo "Note: zsh-copilot has been renamed to zsh-claude"
    echo ""
    zsh-claude
}

# ============================================================================
# ACTIVATION
# ============================================================================

zle -N _suggest_claude_ai
bindkey "$ZSH_CLAUDE_KEY" _suggest_claude_ai
