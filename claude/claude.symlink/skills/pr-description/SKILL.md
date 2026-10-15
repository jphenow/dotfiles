---
name: pr-description
description: The canonical shape and voice for every PR description written by these skills - what the change gets us, the approach, any manual deploy steps (terraform, secrets, migrations the deploy doesn't run), what a human should verify by hand, and the judgment calls worth a second opinion. Use when creating or editing any PR body, whether by hand or from an automated loop.
---

# PR Description

One shape for every PR body these skills write. Four sections, plus **Manual deploy
steps** when the change needs one and **Context** when the work started from something
with a link. Prose, **under 200 words total**, not counting commands in the deploy
section's code block or the links in Context. A reviewer should know within fifteen
seconds whether this matters to them and what they are on the hook for.

```markdown
## What this gets us

<1-3 sentences: what a user, customer, or the product can do now that it couldn't, or what
stops going wrong. Not a restatement of the diff. If the honest answer is "nothing directly
— it unblocks X" or "it pays down Y", write that.>

## Approach

<2-4 sentences: the shape of the implementation. Where the logic lives, what it replaced,
the one structural decision that explains the rest. Enough that a reviewer knows where to
start reading.>

## Manual deploy steps

<ONLY when merging does not fully deploy the change. Omit the heading entirely otherwise —
never write "None". The operations someone must run by hand, in order, with the exact
commands in one code block: `terraform apply` in the right directory and workspace, secrets
to set, a migration or backfill the deploy does not run, DNS, a service or config push. Say
when each runs (before merge, after deploy) and what breaks if it is skipped.>

## Verify by hand

<What automated tests cannot cover: behavior to exercise, environments to check, data to
eyeball. "Nothing — covered by tests in <file>" is a complete answer and the preferred
one.>

## Calls worth a second opinion

<The judgment calls, not the bugs. Where a reasonable engineer would have chosen
differently, where a convention was set that others will follow, where the trade-off was
close. Two or three at most, each one sentence, each naming what you chose and the
alternative. "None — the approach follows <existing pattern>" is a complete answer.>

## Context

<ONLY when the work came from something a reviewer can open. See "Linking context" below.
One line per link: what it is, then the URL.>

---
Closes #<issue>
```

## Deciding whether it needs Manual deploy steps

Check the diff against what actually deploys it, rather than assuming CI covers it:

- **Terraform / infra-as-code** (`*.tf`, `*.hcl`, Pulumi): look in `.github/workflows/`
  and any `Makefile` or deploy script for an `apply`. A `plan`-only job, or no job, means
  the apply is manual.
- **New secrets or env vars** read by the code: manual unless a workflow or script sets them.
- **Migrations or backfills**: manual unless the deploy runs them (for example a
  `release_command` in `fly.toml`, or a migrate step in the deploy workflow).
- **Anything else outside the deployed artifact**: DNS, buckets, IAM, feature-flag
  defaults, config held in another repo or service.

When you can't tell whether something is automated, put it in the section and say so.
That's easier to fix than a step nobody knew about.

## Linking context

Whenever the work started from, or leaned on, something with a URL, link it. A reviewer
should be able to see the evidence the change answers without asking where it came from.
This is not optional when the source exists:

- **Sentry** issues or events, **logs** (Grafana/Loki queries, Fly log search, a log
  excerpt in a gist), **traces** (Tempo/Honeycomb), **dashboards** or metric panels.
- **Slack** threads, incident reports, Discourse or community posts, support tickets.
- Related **issues or PRs** in other repos, and upstream docs or bug reports the fix
  depends on.

Link the specific thing — the Sentry event, the log query with its time range, the Slack
message permalink — not the project's home page. Pull these from the issue body and
comments when the work came from an issue, and from the conversation when it didn't. If a
source was used but has no shareable link (a local log, something pasted into the
session), say what it was in one line rather than dropping it. Keep the section when
rewriting a PR body; rewrites must not lose links an earlier version had.

## Voice

- **Prose, not bullet streams.** Bullets only for genuinely parallel items, three maximum.
  A section that has become a list of eight fragments is a section that was not thought
  through.
- **No file table, no line counts, no test counts.** GitHub already shows the diff, and
  narrating it is the fastest way to be ignored. Name a file only when the reader needs to
  start there.
- **Dry.** No "nice", "cleanly", "robust", "comprehensive", "significantly improves". State
  what it does; let the reader judge.
- **Never a changelog of the review loop.** How many passes ran, what each reviewer found,
  what was fixed in pass 3 — none of that belongs in the description. If a loop needs to
  record itself, it goes in one collapsed `<details>` block at the bottom, or in its single
  closing comment. The sections above stay human-written in tone.
- **Uncertainty is content.** "I am not sure the retry budget is right" is more useful than
  silence, and belongs in "Calls worth a second opinion".

## Before posting

Run the draft through `~/.claude/skills/writing-tropes/SKILL.md` — read it and pass over
the text. These descriptions are read by people, and the tells it catches (negative
parallelism, manufactured emphasis, stakes inflation, bullet padding) are exactly what
makes an automated PR body read like one. Fix what fires; do not mangle a clear sentence
to dodge a pattern.

If the PR was opened from an issue, keep `Closes #<issue>` as the last line so GitHub
links them.
