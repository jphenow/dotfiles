alias reload!='. ~/.zshrc'
if command -v rg >/dev/null 2>&1; then
  alias ack='ag'
  alias ag='rg'
fi
