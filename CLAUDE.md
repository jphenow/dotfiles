# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Personal dotfiles, cloned to `~/.dotfiles`. **The GitHub repo is public.** See README.md for install steps.

## Layout and load order

- `script/bootstrap` (curl entry) clones to `~/.dotfiles` and runs `script/install`, which
  converges the machine: `Brewfile` (+ `Brewfile.extras` with `--extras`) or apt, oh-my-zsh,
  links, one-time config. Every step must check before acting and go through `act` so
  `--dry-run` and the "Nothing to change" idempotency check stay true. Conflicts move
  to `~/.dotfiles-backup/<timestamp>/`. Links: `<topic>/<name>.symlink` -> `~/.<name>`;
  directory `.symlink`s (only `ssh/ssh.symlink`) become a real dir with just their
  git-tracked files linked in. `.config` dirs named in `MACOS_ONLY_CONFIGS` are skipped
  elsewhere. Linux packages are `APT_PACKAGES`; names a release lacks are skipped. Tools
  apt lacks or ships too old (neovim, starship, mise, carapace) come from upstream releases
  into `~/.local/bin` (`install_release_tools`). `setup_nvim_plugins` installs nvim
  plugins at the `lazy-lock.json` commits on first install (lazy.nvim's own first launch
  doesn't). CI runs the real install twice on Ubuntu and checks plugins match the lock.
- `zsh/zshrc.symlink` is `~/.zshrc`. It sets `ZSH_CUSTOM=~/.dotfiles/zsh`, so oh-my-zsh
  auto-sources every `zsh/*.zsh` (alphabetically, so `system.zsh` overrides `aliases.zsh`).
  If oh-my-zsh is missing, zshrc sources those files itself. `zsh/plugins/` is gitignored
  (zsh-autosuggestions is cloned there by the installer).
- `~/.zshrc.local` and `~/.ssh/config.local` are untracked and loaded when present.
- `tmux/tmux.conf.symlink` is upstream oh-my-tmux: **do not edit it**. Customize
  `tmux/tmux.conf.local.symlink`.
- `bin/` is on `PATH`; `git-*` scripts work as `git <name>` subcommands.
- Private keys belong in `~/.ssh`, never in `ssh/ssh.symlink/`. Only `config` is tracked
  there; `.gitignore` excludes the rest, and `script/test` fails if anything else is tracked.
- Agent forwarding is off by default; per-host opt-ins live in `~/.ssh/config.local`, which
  is `Include`d before `Host *` so its values win (ssh uses the first value it sees).
- `<topic>/<name>.config` directories link whole to `~/.config/<name>`: `nvim/nvim.config`
  (LazyVim; add plugins as specs in `lua/plugins/`, extras in `lua/config/lazy.lua`) and
  `karabiner/karabiner.config`. Both apps write back into these dirs.
- `bash/` is older bash config and `vim/init.vim` is unused.

## Rules

- **Nothing private in commits.** Work hostnames, internal repo names, LAN hosts, and
  employer-specific helpers go in `~/.zshrc.local` / `~/.ssh/config.local`, not here.
  Before committing, scan the diff (e.g. `trufflehog git file://. --no-update`).
- **Every machine is different.** Any use of a non-default tool must be skipped quietly
  when it's missing: `command -v foo >/dev/null 2>&1 && ...` in zsh, `if-shell 'test -x ...'`
  in tmux, `IgnoreUnknown` in ssh config. Use `$HOME`, never `/Users/jon`.
- Keep README.md's "Optional tools" table and install section in step with changes.

## Checking changes

```bash
script/test        # syntax, shellcheck, privacy, installer, bare-machine zsh/tmux/ssh startup
```

CI (`.github/workflows/test.yml`) runs it on ubuntu-latest and macos-latest. Checks whose
tool is missing are skipped, so install shellcheck/tmux/trufflehog locally for full coverage.
When adding a missing-tool guard or privacy rule, add a check to `script/test` for it.
