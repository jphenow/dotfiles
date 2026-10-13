# Jon Phenow's dotfiles

zsh (oh-my-zsh + starship), tmux (oh-my-tmux), ssh config, a few ruby/git
files, and scripts in `bin/`. Mostly macOS, but a shell should still start
cleanly on a Linux box that has none of the extras installed.

## Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/jphenow/dotfiles/main/script/install.sh)"
```

or, from a checkout at `~/.dotfiles`:

```bash
~/.dotfiles/script/install.sh            # add --skip-chsh to keep your login shell
```

It's safe to re-run. It:

- installs Homebrew (macOS) and zsh/git if missing, plus `reattach-to-user-namespace`,
  `the_silver_searcher`, `fpp` and `urlview` on macOS; on Linux only curl/zsh/git via apt
- clones this repo to `~/.dotfiles` (or `git pull`s it), installs oh-my-zsh if missing,
  and clones zsh-autosuggestions into `zsh/plugins/`
- symlinks every `<topic>/<name>.symlink` to `~/.<name>`, moving anything in the way to
  `<name>.bak`. `ssh/ssh.symlink` is a directory: `~/.ssh` stays a real directory and
  only the tracked `config` is linked into it.

Then by hand:

```bash
cp ~/.dotfiles/git/gitconfig.symlink.example ~/.gitconfig   # and fill in name/email
brew install starship && starship preset pure-preset -o ~/.config/starship.toml
```

## Optional tools

The shell checks for each of these and skips it when missing:

| Tool | Used for |
| --- | --- |
| [starship](https://starship.rs/) | prompt (without it you get zsh's default) |
| direnv | per-directory env |
| mise | language versions (shims on `PATH`) |
| carapace | completions for commands it has specs for |
| eza, bat, ripgrep | `ls`, `cat`, and `grep`/`ack`/`ag` aliases |
| neovim | `vim` alias |
| grc | colorized command output |
| cursor | `code` alias |
| [Claude Code](https://claude.com/claude-code) | Ctrl-Z command suggestion (`zsh/copilot.zsh`), `git aicm` commit messages |
| gh | `gpo` (push and open the PR) |

The rest of what I usually install:

```bash
brew install coreutils fd jq git procs sd dust tokei hyperfine bottom bandwhich grex delta
brew install autoconf automake openssl wxwidgets libxslt fop libpq overmind stripe libsodium flyctl

git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global merge.conflictStyle zdiff3

brew install tmux nvim
brew install --cask visual-studio-code slack tailscale 1password-cli karabiner-elements \
  spotify discord notion iterm2 signal alfred nordvpn numi postman jordanbaird-ice
```

Docker comes from docker.com.

## Machine-specific config (not in this repo)

The repo is public, so anything tied to work or home hosts lives in untracked
files that are picked up when present:

- `~/.zshrc.local`: sourced at the end of `.zshrc` (work helpers, project aliases)
- `~/.ssh/config.local`: `Include`d by the ssh config (LAN hosts)
- `~/.gitconfig`: copied from the example above
- `tmux.boot.sh`: gitignored work tmux layout

Private keys stay in `~/.ssh`, never in `ssh/ssh.symlink/`. Only `config` is tracked
there and `.gitignore` excludes everything else, but keep keys out of the repo anyway.

## Terminal

- iTerm: load `Default iTerm2 Profile.json` and `iTermKeyMap.itermkeymap` from this
  folder. Colors are tweaked from <https://www.iterm2material.design/>.
- Ghostty: its config isn't in this repo. The tmux sp-paste binding expects
  Cmd-Shift-V to send `M-C-v`.
- Font: `Menlo-Powerline.otf`.

## Checking changes

`script/test` checks syntax, shellcheck, that nothing private is tracked, the
installer's symlinking, and that zsh/tmux/ssh start cleanly on a bare machine.
CI runs it on Linux and macOS.

## Not managed here

- Neovim config lives in `~/.config/nvim`. `vim/init.vim` is an old vim-plug config
  that nothing links.
- `bash/` holds older bash config; the zsh setup doesn't use it.

## Other useful tools

- [k9s](https://k9scli.io/)
- key-repeat for VS Code vim: https://vimforvscode.com/enable-key-repeat-vim
- shell history: https://atuin.sh/docs/advanced-install

## Inspo

- https://zaiste.net/posts/shell-commands-rust/
