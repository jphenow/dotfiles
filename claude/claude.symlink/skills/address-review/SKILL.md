---
name: address-review
description: Address all findings from a prior /code-review (or similar review) in the current conversation -- ask clarifying questions, fix issues, add tests, update docs, commit in logical chunks, push, and update the PR description.
disable-model-invocation: true
argument-hint: ""
---

# Address Review Findings

You are addressing the review findings produced earlier in this conversation (typically from `/code-review`). The review output is already in context — do **not** re-run the review. If no review is present in the conversation, stop and tell the user.

**Default scope: address everything.** That means BLOCKING, SHOULD_FIX, **and NITs** — do not silently drop nits as "not worth it." If you think a specific item genuinely shouldn't be fixed, surface it to the user as a question rather than skipping it.

**Default on questions: discuss them.** Every open question the reviewer raised must be talked through with the user before you act on it. Do not pick an answer unilaterally.

## Step 1: Inventory

List every actionable item from the review in one place, including:

- BLOCKING / SHOULD_FIX / NIT issues
- Open questions the reviewer raised
- Missing acceptance criteria from the linked issue
- Test coverage gaps
- Doc / CLAUDE.md / `.claude/rules/` updates implied by the changes

Group related items so they can be fixed and committed together.

## Step 2: Clarify Before Fixing

**Every open question from the review gets discussed with the user — no exceptions.** Also ask about any item where the fix direction is ambiguous, the tradeoffs are non-obvious, or you think an item maybe shouldn't be fixed at all. Batch questions together using `AskUserQuestion` rather than asking one at a time. Do not assume — per global CLAUDE.md, design decisions require explicit user input.

Mechanical NITs (typos, formatting, obvious renames) can be fixed without asking, but they still get fixed — nits are in scope by default.

## Step 3: Fix in Logical Chunks

Work through the inventory group by group. For each group:

1. Make the code changes.
2. **Sweep for siblings — required, not optional.** A fix at one call site is not a fix. After
   changing something, grep the changed packages for the same pattern: the same predicate, the
   same field read, the same sentinel or empty-string handling, the same helper called with the
   same shape of argument. Search by construct, not by the line you edited. Fix every match that
   has the same defect, and in RESULT_FIXED (or the Step 7 report) say what the sweep matched and
   what you did with each match — including matches you decided were fine, and why. A fix reported
   with no sweep is incomplete.
3. Add or update tests when the change is testable and tests would have caught the issue. Skip tests for pure refactors, comments, or doc-only changes.
4. Update `CLAUDE.md`, `.claude/rules/*`, `deploy.yml`, or other docs if the change affects architecture, workflow, or configuration (per project CLAUDE.md).
5. Run the relevant checks before committing:
   - Go: `gofmt`, `go test -race ./...` (or scoped package tests for fast iteration, full suite before push)
   - Frontend: `npm run lint`, `npm test`
   - Whatever the project's `make ci` / equivalent runs
6. Stage **specific files by name** (never `git add -A` / `git add .`) and commit with a focused message.

If a check fails, fix the root cause before moving on — do not push and iterate.

## Step 4: Final Verification

Before pushing:

- Run the **full** test suite (not just the scoped subset).
- `git status` — confirm no stray unstaged changes or unmerged paths.
- `git log` — confirm the commit history tells a clean story.

## Step 5: Push

```bash
git push
```

If the branch has diverged, investigate before force-pushing — never force-push without explicit user confirmation.

## Step 6: Update PR Description

If the changes meaningfully alter the PR's scope, behavior, testing story, or risk profile, update the PR body with `gh pr edit <num> --body ...`. If the changes were small/cosmetic and the existing description still reads accurately, leave it alone and say so.

When you do rewrite it, keep the Context section and every link in it, and add links for anything new the fixes leaned on (a Sentry event, a log query, a Slack thread). See `~/.claude/skills/pr-description/SKILL.md`.

## Step 7: Report

Summarize for the user:

- What was fixed (grouped by commit)
- What was deferred or rejected, and why
- Any follow-ups worth a separate PR or issue
- PR description: updated / left as-is

## Guardrails

- Do **not** capitulate on review findings you disagree with — push back with reasoning if the reviewer was wrong, and surface the disagreement to the user rather than silently "fixing" something that wasn't broken.
- Do **not** expand scope beyond the review. New refactors, cleanups, or "while I'm here" changes require explicit user approval.
- Do **not** remove existing comments during edits.
- Do **not** post anything to GitHub except the final push and (if warranted) the PR description edit. No PR comments, no review submissions.
