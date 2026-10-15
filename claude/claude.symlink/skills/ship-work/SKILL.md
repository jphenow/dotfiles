---
name: ship-work
description: Ship work that is not (or not only) a GitHub issue -- follow-ups from this conversation, a prompt describing a change, or a mix with issue numbers. Builds a spec from the prompt and/or conversation context, applies the user's direction (skip X, combine Y and Z), groups items into PRs, and ships each group sequentially with the ship-issue loop, each on its own branch off main. Never waits on the user; safe to run from a subagent when the prompt carries the spec.
argument-hint: "[what to ship and any direction: skips, grouping, constraints]"
---

# Ship Work

You turn a description of work into one or more open PRs, **unattended**. The engine is
`~/.claude/skills/ship-issue/SKILL.md`; this skill only decides *what* to ship and in which
PRs, then runs that engine once per PR.

Read `~/.claude/skills/ship-issue/SKILL.md` now. Its Decision Policy, Phases 1–5, and
Guardrails apply here unchanged unless this file says otherwise.

---

## Phase 0: Build the work list

### Sources, in priority order

1. **`$ARGUMENTS`**: the user's words for this run. It may be a full spec ("add a retry to
   X when Y"), a pointer ("the follow-ups you listed above"), direction ("skip the nil-channel
   one", "put A and B in one PR"), issue numbers, or any mix.
2. **This conversation**: when `$ARGUMENTS` points at it or is empty. Look for proposed
   follow-ups, deferred items, "we should also…", TODOs agreed on, and items in an earlier
   `SHIP_FOLLOWUPS` block. Take only what was proposed or agreed, not every idea mentioned
   in passing.
3. **Issue numbers** named in either: read them as ship-issue Phase 0 does, and carry
   `Closes #N` into that item's PR.

If there is neither `$ARGUMENTS` nor usable conversation context (typical when run as a
fresh subagent with no prompt), stop with `SHIP_STATUS: blocked` and say what input was
missing. Never invent work.

### Apply the direction

- **Skips** are absolute. Record each skipped item with the user's reason, quoted; it goes
  in the report and nowhere else. Do not file issues for skipped items.
- **Constraints** the user stated (sequential, single commit, base on main, don't touch X)
  override the defaults below when they conflict.
- An item that is ambiguous after reading the conversation and the code: take the
  smallest-scope reading (Decision Policy rule 1) and log it in `DECISIONS`. An item you
  cannot turn into a concrete change at all: skip it and report it as "needs a spec".

### Group into PRs

Default: **collapse into as few PRs as stay reviewable.** Items share a PR when they touch
the same module or one can't be reviewed sensibly without the other. Give an item its own PR
when it is independently revertible and unrelated, or when it carries deploy risk the others
don't (a migration, a config or infra change). The user's grouping direction wins over this.

Every group must stand alone on `origin/main`. If group B only makes sense after group A
merges, merge them into one group instead of stacking branches.

### Print the plan, then continue

```
| # | PR title | Items | Branch | Closes |
|---|----------|-------|--------|--------|
Skipped: <item> (<user's reason>)
```

No approval gate, unless `$ARGUMENTS` asks for one ("show me the plan first"). In that case
print the plan, stop, and report `SHIP_STATUS: planned`.

Each group becomes:

```
SPEC_TITLE = <PR title>
SPEC       = <the group's items as concrete requirements, including any conversation
              detail they depend on: file paths, function names, the reasoning that led to them>
CLOSES     = <#N for any issues in the group, or none>
CONTEXT    = <URLs from the conversation or issues that this group leans on>
```

Write `SPEC` so a reader with no access to this conversation could implement it. Review
subagents only ever see `SPEC`.

---

## Phase 1..N: Ship each group, sequentially

One group at a time, in plan order, never in parallel. Groups share one working tree.

For each group, run ship-issue **Phases 1–5** with that group's `SPEC_*`/`CLOSES`/`CONTEXT`,
starting from Phase 1 (branch off `origin/main`). Two differences:

- Phase 1 must start clean: after the previous group, `git switch` back to the default
  branch and confirm `git status --porcelain` is empty. The new branch comes from a fresh
  `git fetch origin` and `origin/main`, never from the previous group's branch.
- Keep `DECISIONS` per group; each PR's description gets only its own.

If a group ends `blocked` or `failed`, record it and move on to the next group. Its branch
stays local (or pushed, in ci mode) for a human to pick up.

---

## Report

A short human summary: one line per PR (title, URL, CI state), the skipped items with
reasons, and anything that needs a human. Then, for a parent agent, one ship-issue
`SHIP_*` block per group, followed by:

```
SHIP_WORK_SKIPPED: <item (reason)> OR none
SHIP_WORK_FOLLOWUPS: <deferred items across all groups> OR none
```
