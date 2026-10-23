---
name: jj
description: How to use Jujutsu (jj) in repos that are colocated with git and hosted on GitHub - the working-copy-as-commit model, bookmarks instead of branches, pushing and making PRs, and the non-interactive flags an agent needs. Use whenever committing, branching, rebasing, pushing, or opening a PR in a repo that has a .jj directory, and whenever a jj command errors or a repo's history needs untangling.
---

# Jujutsu in a git-backed repo

Use jj only where the repo already has a `.jj` directory. Everywhere else, use git as
normal. **Never run `jj git init --colocate` or `jj git colocation enable` on a repo without
being asked to** — it changes how the human works in that repo.

Check before assuming: `test -d .jj` or `jj git colocation status`.

Colocated means both tools work on the same repo. jj imports git's refs at the start of every
jj command and exports its own at the end, so `gh` keeps working and a teammate sees an
ordinary git repo. It also means **you don't need git for anything here** — mixing them is how
state gets confusing.

## The model, in three facts

1. **The working copy is a commit.** `@` is a real commit that updates as you edit files.
   There is no staging area and no "unstaged changes"; `git add` has no equivalent because
   it has no purpose.
2. **Every command snapshots first.** You never lose work by switching revisions, and you
   never need `git stash`.
3. **Commits are meant to be rewritten.** A change keeps a stable change ID while its commit
   hash changes underneath. Amending history is the normal workflow, not a recovery step.

An empty `@` sitting on top of your work is the normal resting state, not a mistake.

**jj does not read git's user config.** Identity lives in `~/.config/jj/config.toml`.
If jj warns "Name and email not configured ... can't be pushed
to remotes", that file is missing — write it rather than committing with an empty identity:

```toml
[user]
name = "Your Name"
email = "you@example.com"
```

## The loop

```bash
jj st                        # what's in the working copy, and where @ sits
jj log                       # the graph; @ is the working copy
jj new -m "add the thing"    # start a new change, then edit files
jj describe -m "better msg"  # retitle the current change
jj commit -m "done"          # describe @ and start a fresh change on top
```

Two orders work, and both are fine: describe first with `jj new -m`, then edit; or edit
first and `jj describe -m` afterwards.

## Stacking and fixing

```bash
jj new                       # stack a new change on @
jj edit <rev>                # move the working copy to an earlier change to fix it
jj squash                    # fold @ into its parent
jj squash --into <rev>       # fold @ into a specific ancestor
jj absorb                    # distribute @'s edits into whichever ancestors touched those lines
jj rebase -d <rev>           # move a change (and descendants) onto a new parent
jj undo                      # undo the last jj operation
jj op log                    # every operation, for when undo isn't enough
```

`jj absorb` is the one worth reaching for: after fixing several things in one working copy,
it files each hunk into the ancestor that introduced that code.

Descendants rebase automatically when you edit an ancestor. Conflicts don't block that —
they get recorded *in* the commit, `jj st` shows them, and you resolve them whenever you
like by editing the files (or `jj resolve` with a merge tool).

## Bookmarks are not branches

jj has no current branch. A bookmark is a name pointing at a commit, and **it does not
follow your work** — you move it deliberately.

```bash
jj bookmark list
jj bookmark set my-feature -r @-          # create or move it; @- is usually what you want
jj git push --bookmark my-feature --allow-new
jj git push -c @                          # or: push this change, auto-creating push-<changeid>
jj git push --dry-run                     # check what would move
```

Use `-r @-` rather than `-r @` when `@` is the empty working copy on top. `--allow-new` is
required the first time a bookmark is pushed.

Then open the PR with `gh` as usual:

```bash
gh pr create --head my-feature --base main --title "..." --body "..."
```

## Syncing with the remote

```bash
jj git fetch
jj rebase -d main@origin     # or -d trunk()
jj log -r 'trunk()..@'       # what this branch adds on top of trunk
```

`main@origin` is the remote-tracking bookmark. `trunk()` resolves to the main branch of the
default remote — in a repo with no remote it quietly resolves to the root commit, so prefer
naming the bookmark explicitly when you're not sure a remote exists.

## Revsets worth knowing

`@` working copy · `@-` its parent · `trunk()` main branch · `mine()` your commits ·
`::@` ancestors of `@` · `trunk()..@` what you've added · `conflicts()` anything conflicted.

```bash
jj log -r 'trunk()..@'
jj log -r 'mine() & ~::trunk()' --limit 10
```

## Rules for running jj non-interactively

- **Always pass `-m`.** `jj describe`, `jj commit` and `jj split` open `$EDITOR` without it,
  which hangs a non-interactive session.
- **Avoid the interactive commands entirely**: `jj split`, `jj diffedit`, `jj arrange`, and
  `jj resolve` without a configured tool all want a terminal. Use `jj squash --into`,
  `jj absorb`, or restore specific paths with `jj restore -r <rev> <path>` instead.
- **Don't fight immutability.** "Commit is immutable" means you're rewriting something on
  trunk or already pushed. Build on top with `jj new` rather than overriding the check.
- **Don't use git to change anything** in a colocated repo — no `git add`, `git commit`,
  `git rebase`, `git push`. Reading is harmless (`git log`, `git diff`), and `gh` is fine.

## When something looks wrong

`jj undo` reverses the last operation, including a bad rebase or squash. `jj op log` shows
the full history of operations and `jj op restore <id>` returns the whole repo to that
point. Nothing is lost by trying something; the operation log is the safety net that makes
rewriting history routine.

If the repo looks out of step with git after someone ran git commands, `jj git import`
re-reads git's refs and `jj git export` writes jj's back.
