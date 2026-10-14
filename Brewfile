# Core tools the shell, tmux and nvim config use. Installed by script/install.
# Everything here is optional at runtime: the config skips what's missing.

# brew resets PATH before reading this file; HOMEBREW_PATH is the caller's PATH
def on_path?(cmd) = ENV.fetch("HOMEBREW_PATH", ENV["PATH"]).split(":").any? { |d| File.executable?(File.join(d, cmd)) }

brew "mise" unless on_path?("mise") # language versions; often installed by its own script

brew "git"
brew "zsh"
brew "tmux"
brew "neovim"
brew "starship"   # prompt
brew "direnv"
brew "carapace"   # completions
brew "ripgrep"
brew "eza"
brew "bat"
brew "fd"
brew "jq"
brew "grc"
brew "coreutils"
brew "gh"         # bin/gpo
brew "git-delta"
brew "shellcheck" # script/test
brew "urlview"    # oh-my-tmux URL picker
brew "fpp"        # oh-my-tmux path picker
