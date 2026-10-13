# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Personal dotfiles, cloned to `~/.dotfiles`. **The GitHub repo is public.** See README.md for install steps.

## Layout and load order

- `script/install.sh` symlinks every `<topic>/<name>.symlink` to `~/.<name>`. Directory
  `.symlink`s (only `ssh/ssh.symlink`) become a real `~/.<name>` dir with just their
  git-tracked files linked in. Any other `<topic>/install.sh` is run too (none exist now).
- `zsh/zshrc.symlink` is `~/.zshrc`. It sets `ZSH_CUSTOM=~/.dotfiles/zsh`, so oh-my-zsh
  auto-sources every `zsh/*.zsh` (alphabetically, so `system.zsh` overrides `aliases.zsh`).
  If oh-my-zsh is missing, zshrc sources those files itself. `zsh/plugins/` is gitignored
  (zsh-autosuggestions is cloned there by the installer).
- `~/.zshrc.local` and `~/.ssh/config.local` are untracked and loaded when present.
- `tmux/tmux.conf.symlink` is upstream oh-my-tmux: **do not edit it**. Customize
  `tmux/tmux.conf.local.symlink`.
- `bin/` is on `PATH`; `git-*` scripts work as `git <name>` subcommands.
- On this Mac, `~/.ssh` is a symlink to `ssh/ssh.symlink/`, so private keys sit in the
  working tree. Only `config` is tracked; `.gitignore` excludes the rest. Never `git add -f`
  anything there or loosen that ignore rule.
- `bash/` is older bash config and `vim/init.vim` is unused (nvim config lives in
  `~/.config/nvim`, outside this repo).

## Rules

- **Nothing private in commits.** Work hostnames, internal repo names, LAN hosts, and
  employer-specific helpers go in `~/.zshrc.local` / `~/.ssh/config.local`, not here.
  Before committing, scan the diff (e.g. `trufflehog git file://. --no-update`).
- **Every machine is different.** Any use of a non-default tool must be skipped quietly
  when it's missing: `command -v foo >/dev/null 2>&1 && ...` in zsh, `if-shell 'test -x ...'`
  in tmux, `IgnoreUnknown` in ssh config. Use `$HOME`, never `/Users/jon`.
- Keep README.md's "Optional tools" table and install section in step with changes.

## Checking changes

There are no tests. Verify by hand:

```bash
zsh -n zsh/zshrc.symlink                       # syntax
zsh -i -c exit                                 # real startup should print nothing
# bare-machine startup: fake HOME, minimal PATH
T=$(mktemp -d); ln -s ~/.dotfiles "$T/.dotfiles"; ln -s ~/.dotfiles/zsh/zshrc.symlink "$T/.zshrc"
env -i HOME="$T" TERM=xterm PATH=/usr/bin:/bin zsh -i -c 'echo ok'
shellcheck script/install.sh bin/<script>
ssh -G -F ssh/ssh.symlink/config <host>        # ssh config parses / resolves
tmux -L test -f tmux/tmux.conf.symlink new -d && tmux -L test list-keys; tmux -L test kill-server
```
