---
name: ship-issue
description: Autonomous end-to-end loop for one GitHub issue -- implement on a branch off main, iterate tests and fresh-context review passes locally until a review comes back clean, then push once and open a PR with a strong description and confirm CI passes. Falls back to pushing and iterating against CI only when local tests cannot run. Never waits on the user; safe to run from a subagent.
argument-hint: "<issue-number>"
---

# Ship Issue #$ARGUMENTS

You are taking GitHub issue #$ARGUMENTS from spec to an open PR, **unattended**. Nobody is
watching. Do not ask questions; resolve every judgment call with the Decision Policy and
note the ones a human would want to weigh in on.

The shape of a run:

1. **Spec** — read the issue and its comments.
2. **Implement** — on a fresh branch off `origin/main`.
3. **Iterate locally** — tests plus fresh-context review passes until a review is clean.
   Nothing leaves the machine during this phase.
4. **Publish** — push once, open the PR.
5. **Confirm CI** — watch it to green.
6. **Report** — to whoever invoked you (a user or a parent agent).

The goal is a PR that reads like a careful human wrote it: one commit (or a few logical
ones), a strong description, green CI, and no machine-written review logs on GitHub.

`/ship-work` reuses Phases 1–5 with a spec built from a prompt instead of an issue. Where
this file says "the issue", read "the spec" when invoked that way.

---

## Decision Policy

Applies to you and to every subagent you dispatch.

1. **Take the recommended default.** When the issue, a comment, or a reviewer offers options
   with a suggestion, take it. With no suggestion, pick the option smallest in scope and
   easiest to reverse.
2. **Latest consensus in issue comments beats the issue body.** On unresolved disagreement,
   go with the repo owner's most recent position; if the owner never weighed in, the
   smallest-scope reading.
3. **Push back by rejecting, not by stopping.** A review finding that looks wrong or
   conflicts with an explicit choice in the spec is rejected with a reason, not fixed and
   not escalated.
4. **Keep a `DECISIONS` list in memory**: `{what, alternatives, why}` for every
   non-mechanical call. It feeds the PR's "Calls worth a second opinion" and the final
   report. It is never posted to GitHub as a log.
5. **Never destructive on shared state:** no force-push, no rewriting pushed history, no
   deleting branches, no closing PRs. Rewriting *local, unpushed* commits is fine and
   expected.

---

## Phase 0: Spec

```bash
gh issue view $ARGUMENTS --json number,title,body,labels,url
gh issue view $ARGUMENTS --comments
```

Extract requirements, scope changes made in comments, design decisions and rejected
alternatives, "don't do X" warnings, and every context URL (Sentry, logs, traces,
dashboards, Slack, incidents, related PRs). The URLs go in the PR's Context section.

If the issue is blocked on unmerged work, stop and report `blocked`. Do not stack branches.

Record:

```
SPEC_TITLE = <issue title>
SPEC       = <requirements, after applying comments>
CLOSES     = #$ARGUMENTS
CONTEXT    = <urls>
```

---

## Phase 1: Branch and implement

In a repo with a `.jj` directory, do every git step below with jj instead (load the `jj`
skill).

```bash
git fetch origin
git status --porcelain     # must be empty; if not, stop and report. Never stash someone's work.
git switch -c <owner>/<short-kebab-description> origin/main
```

If the branch name is taken locally or on the remote, append `-v2`.

Explore the code the spec touches before editing. Read the repo's `CLAUDE.md` and
`.claude/rules/` and follow them (TDD where the repo mandates it). Implement the whole spec;
anything beyond it becomes a follow-up in the report, not part of this branch.

Commit locally as often as is useful; Phase 3 squashes before anything is pushed. Stage
files by name, never `git add -A` / `git add .`.

---

## Phase 2: Iterate locally

### 2a. Find and prove the local checks

Find the repo's check commands, in this order of authority: `CLAUDE.md` / `.claude/rules/`,
then `Makefile` targets (`make ci`), then the steps in `.github/workflows/*.yml`. Record them
as `CHECKS`.

Run them. Make a real attempt to get them working: fetch declared deps, start services the
repo documents (a local DB, LocalStack), follow the README's dev setup. Do not install
anything the repo doesn't declare, and do not edit project config to make tests runnable.

```
MODE = local   # CHECKS run here (pass or fail on their merits)
MODE = ci      # CHECKS cannot run here after a real attempt; record why
```

A failing test is not a reason for `ci` mode; fix it. `ci` mode is for "the harness cannot
run": missing service, missing credentials, unsupported platform. If only part of the suite
can run (say, everything but integration tests), stay `local`, run what runs, and let
Phase 4 cover the rest.

### 2b. Get checks green

**local:** run `CHECKS` until green.

**ci:** CI becomes the test runner, so publish early. Squash to one commit (Phase 3's
rule) and push. Check how CI is triggered (`on:` in the workflows); if it runs only on
`pull_request`, open the PR now **as a draft**, with the body written per Phase 3. Then:

```bash
gh run list --branch <branch> --limit 5
gh run watch <run-id> --exit-status         # or: gh pr checks <pr> --watch
gh run view <run-id> --log-failed
```

Fix, commit, push, re-watch. The branch is public now, so fixes are new commits on top;
never amend or force-push. Batch fixes so each push answers everything the last run
reported.

### 2c. Review loop (fresh context per pass)

```
ITERATION      = 0
MAX_ITERATIONS = 4
SKIPPED        = []   // rejected/deferred findings, by file + description, with reason
FIXED          = {}   // finding (file + description) -> times a fix pass reported it fixed
```

Each pass reviews the branch as committed: `origin/main...HEAD`. Commit any work before
dispatching and record `REVIEWED = $(git rev-parse HEAD)`.

**Fresh context is the point**: a new subagent per pass means no review inherits the last
one's framing. Launch ONE `Agent` (`subagent_type: "general-purpose"`) per pass. If the
Agent tool is unavailable (you are a subagent that cannot spawn), run the pass inline:
re-read the diff from scratch, set aside your memory of writing it, and note "reviews ran
inline" in the report.

The **final** pass must be unsteered: no focus areas, no carried-forward items, no hint of
what the last pass fixed. Add the threat-model bullet to that pass only.

Review prompt (paste `~/.claude/skills/code-review/SKILL.md` where indicated):

```
You are performing a fresh, independent code review of local branch {BRANCH} in {REPO_PATH}
against origin/main. It implements: {SPEC_TITLE}. Spec:
{SPEC}

There is no PR yet. Follow the review instructions below with these overrides:

- Review scope is `git diff origin/main...HEAD` and `git log origin/main..HEAD` in
  {REPO_PATH}. Skip every `gh pr ...` command, the Phase 1b eligibility check, and Phase 1c;
  the spec above stands in for the linked issue. Repo-convention research through merged
  PRs is still in scope.
- Run Phases 1–4 only. No fix workflow, no questions, and no writes of any kind: do not
  edit, commit, stash, or check out anything. Another process owns this working tree.
- Do not re-raise anything below unless you have NEW evidence it is a real bug, and then say
  why the recorded reasoning is wrong:
  {SKIPPED with reasons}
- For every open question, give a recommended answer; it will be taken as given.
- You are pass {ITERATION} of at most {MAX_ITERATIONS}. Pass 3+: report docs or comments
  only when they make a false claim about the code. Pass 4: no wording findings at all.
- A previous fix is not a defect because you'd have written it differently; ask whether it
  is wrong, not whether it is optimal. An empty finding list is a valid review.
[UNSTEERED PASS ONLY]
- You have deliberately been given no focus areas. Of each risky construct ask "what threat
  model makes this dangerous?" (what it can reach, what touches it concurrently, whose
  resources besides the intended ones match it) and state the threat models you considered
  for each construct you cleared.

End with exactly:

REVIEW_VERDICT: ready-to-merge OR changes-needed
  (ready-to-merge: nothing must change before this lands; listed nits don't change that)
REVIEW_WORDING_ONLY: yes OR no
REVIEW_BLOCKING: <count>
REVIEW_SHOULD_FIX: <count>
REVIEW_NITS: <count>
REVIEW_FINDINGS:
<each finding: severity, file:line, problem, suggested fix; open questions with recommended answers>

=== BEGIN code-review SKILL ===
{body of ~/.claude/skills/code-review/SKILL.md}
=== END code-review SKILL ===
```

Increment `ITERATION` and print one line to the terminal (`pass N: verdict, B/S/N`). That is
the only running log.

**Converged** when, after excluding findings that match `SKIPPED`, the verdict is
`ready-to-merge` (or blocking and should-fix are both 0), **and** `git log {REVIEWED}..HEAD`
is empty: nothing on the branch is unreviewed. Nits never earn a fix pass.

If commits landed after the last clean review, run one more unsteered pass over the whole
branch. This doesn't count against `MAX_ITERATIONS`, but three such tail passes in a row
that each produce changes means the branch isn't settling; stop.

**Stop without converging** (say so in the report) when:

- `ITERATION == MAX_ITERATIONS`;
- two consecutive passes are `REVIEW_WORDING_ONLY: yes`: the loop is polishing prose;
- a finding already in `FIXED` comes back. The second time, reject it as "reviewer
  disagreement, left as fixed" and add it to `SKIPPED`; the third time, stop.

**Resolve** the remaining findings here, without a user: open question → the recommended
answer; contradicts the spec or an earlier decision → rejected, into `SKIPPED`; widens scope
→ deferred to a follow-up, into `SKIPPED`; everything else → fix. Log non-mechanical calls in
`DECISIONS`.

**Fix pass:** ONE `Agent` (`general-purpose`), or inline under the same fallback. Paste
`~/.claude/skills/address-review/SKILL.md` where indicated:

```
You are fixing review findings on local branch {BRANCH} in {REPO_PATH}. The review is below;
do not re-run it. Follow the address-review instructions with these overrides:

- There is no user; never ask. The decisions are already made (below); apply them. Do NOT
  fix anything marked rejected or deferred. For a call the decisions don't cover, pick the
  smallest, most reversible option and report it.
- Run {CHECKS} before finishing ({MODE} = ci: run whatever subset can run here).
- Commit locally, staging files by name. {MODE} = local: do NOT push. {MODE} = ci: push once
  at the end, never force-push; if the push is rejected, `git pull --rebase` and push again.
- Do not touch any PR description and post nothing to GitHub.

End with exactly:
RESULT_STATUS: success OR failed
RESULT_FIXED: <one line per finding, "file: what changed"> OR none
RESULT_NOT_FIXED: <finding + reason> OR none
RESULT_DECISIONS: <call + alternatives + why> OR none

=== DECISIONS ===
{this pass's answers, rejections, deferrals}
=== REVIEW FINDINGS ===
{REVIEW_FINDINGS}
=== BEGIN address-review SKILL ===
{body of ~/.claude/skills/address-review/SKILL.md}
=== END address-review SKILL ===
```

Merge `RESULT_FIXED` into `FIXED` and `RESULT_DECISIONS` into `DECISIONS`. On `failed`,
retry once with the error appended; a second failure ends the loop (report it; leave any PR
a draft). A finding not fixed twice becomes deferred. Then run the next review pass.

---

## Phase 3: Publish

Skip whatever `ci` mode already did (the branch is pushed; a draft PR may exist).

**Shape the history** (local mode, nothing pushed yet). The default is one commit:

```bash
git reset --soft origin/main      # only while nothing has been pushed
git commit                        # <type>: <summary> (#N); body explains why
```

Keep more than one commit only when they are separately meaningful to a reviewer, such as a
mechanical rename and the behavior change that needed it. Never commits like "address
review" or "fix test".

Final gate: `CHECKS` green on exactly this tree, and `git log origin/main..HEAD --oneline`
shows the commits you intend.

```bash
git push -u origin <branch>
```

**PR description:** read and follow `~/.claude/skills/pr-description/SKILL.md`: four
sections, prose, under 200 words, plus Manual deploy steps and Context when they apply, run
through `writing-tropes`. Put the two or three `DECISIONS` a human would actually weigh in on
(a close trade-off, a convention this sets, a rejected finding the owner might disagree with)
into **Calls worth a second opinion**. The rest of `DECISIONS` stays off GitHub: no collapsed
review log, no pass counts, no "automated review" detail. End the body with `Closes #N` when
there is an issue, then any attribution line the session requires.

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
...
EOF
)"
```

In `ci` mode with a draft already open: `gh pr edit <pr> --body ...` now, and
`gh pr ready <pr>` once Phase 4 is green.

---

## Phase 4: Confirm CI

If the repo has CI (workflows exist, or `gh pr checks` lists checks):

```bash
gh pr checks <pr> --watch --fail-fast
```

On failure: `gh run view <id> --log-failed`, reproduce it locally when `MODE = local`, fix,
run `CHECKS`, commit, and push a new commit on top (the branch is public now). Watch again.
Up to 3 rounds. Never call a failure flaky to get past it; if a test failed once and passed
on rerun, say so in the report. Still red after 3 rounds: convert to draft
(`gh pr ready <pr> --undo`) and report.

A fix pushed here is unreviewed. If it is more than mechanical (logic, not format or lint),
run one unsteered review pass over the whole branch before reporting.

No CI configured: say so in the report; local `CHECKS` were the gate.

---

## Phase 5: Report

Write a short human summary, then end with this block so a parent agent can parse it:

```
SHIP_STATUS: shipped OR shipped-ci-red OR blocked OR failed
SHIP_PR: <url> OR none
SHIP_BRANCH: <branch>
SHIP_MODE: local OR ci (<why ci>)
SHIP_REVIEW: converged after N passes OR cap hit OR wording churn OR reviewer disagreement
SHIP_CI: green OR red (<failing check>) OR none configured
SHIP_DECISIONS: <one line per DECISIONS entry>
SHIP_FOLLOWUPS: <one line per deferred item> OR none
SHIP_MANUAL_DEPLOY: <verbatim from the PR> OR none
```

---

## Guardrails

- GitHub writes are limited to pushes, `gh pr create`, `gh pr edit` of the body, and
  `gh pr ready`. No PR comments, no review submissions, no issue comments, no new issues.
- Pushes are rare: once in local mode (plus any CI fixes); batched per CI run in ci mode.
- Never force-push, and never amend after a push.
- Stage files by name.
- Never dismiss a failing test as flaky.
- If interrupted, leave the branch committed (pushed, in ci mode) and report where it stands.
