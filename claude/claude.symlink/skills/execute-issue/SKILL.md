---
name: execute-issue
description: Implement an approved plan for a specific GitHub issue. Creates a feature branch, implements changes with incremental commits, runs tests, and opens a PR.
disable-model-invocation: true
argument-hint: "<issue-number>"
---

# Execute Approved Plan for Issue #$ARGUMENTS

You are implementing the approved plan for GitHub issue #$ARGUMENTS.

## Step 0: Load the Plan

Fetch the full issue body and comments to understand the requirements:

```
gh issue view $ARGUMENTS --json title,body,labels
gh issue view $ARGUMENTS --comments
```

**Evaluate comments for:**
- **Scope changes** — requirements added, removed, or modified after the original issue was filed
- **Design decisions** — agreed-upon approaches, rejected alternatives, or architectural constraints
- **Clarifications** — answers to ambiguous points in the issue body
- **Blockers or warnings** — dependencies, known pitfalls, or "don't do X" guidance from reviewers
- **Approval status** — whether the approach was explicitly approved or if discussion is still open
- **Context links** — Sentry issues, log queries, traces, dashboards, Slack threads, incidents, related issues/PRs. Collect every URL now; they go in the PR's Context section (see `~/.claude/skills/pr-description/SKILL.md`)

If comments contradict or refine the issue body, **the latest consensus in comments takes precedence** over the original description. If comments show unresolved disagreement or open questions, surface those to the user before proceeding.

If `/plan-issues` was run previously in this session, reference that plan but cross-check it against any comments posted after the plan was created. Otherwise, explore the codebase to build your own understanding of what needs to change (following the same structure as the plan-issues skill would produce).

Confirm with the user: "I'm about to implement issue #$ARGUMENTS: {title}. Here's my implementation plan: {brief summary}. {any notable context from comments}. Proceed?"

## Step 1: Branch Setup

```bash
git fetch origin
git checkout main
git pull origin main
git checkout -b <branch-name>
```

Branch naming convention: `{repo-owner}/{short-kebab-description}` (e.g., `jphenow/retry-backoff-on-timeouts`).

If the branch already exists locally or on the remote, ask the user whether to reuse it or create a fresh one.

## Step 2: Incremental Implementation

For each logical step in the plan:

1. **Make the code changes** for that step.
2. **Run relevant tests** after each change:
   - Go changes: `go build ./... && go test -v -race ./...`
   - Frontend changes: `cd web && npm test`
   - Both: `make ci`
3. **Commit** with a descriptive message:
   - Format: `<type>: <description> (#$ARGUMENTS)`
   - Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`
   - Example: `feat: add parallel worker pool to GCS uploads (#20)`
4. **If tests fail**, fix the issue before committing. Do not commit broken code.
5. **Create a checkpoint** after each successful commit (if the Sprite skill is available).

Important: Keep commits atomic and meaningful. Each commit should represent one logical unit of work that compiles and passes tests independently.

## Step 3: Final Verification

After all implementation steps are complete:

```bash
make ci
```

If CI fails, fix issues and add a new commit. Do not amend previous commits.

Review the full diff against main:

```bash
git diff main...HEAD --stat
git log main..HEAD --oneline
```

Confirm with the user that everything looks correct before pushing.

## Step 4: Push and Open PR

```bash
git push -u origin <branch-name>
```

Open a PR:

Write the body per `~/.claude/skills/pr-description/SKILL.md` — read that file and follow
it: four sections (What this gets us / Approach / Verify by hand / Calls worth a second
opinion), plus Manual deploy steps when merging does not fully deploy the change
(unautomated terraform, secrets, migrations), plus Context links whenever the work came
from Sentry, logs, traces, dashboards, Slack threads, or other linkable sources. Prose, under 200 words, no file table, run
through `writing-tropes` before posting.

```bash
gh pr create --title "<issue-title>" --body "$(cat <<'EOF'
<the four sections>

---
Closes #$ARGUMENTS
EOF
)"
```

## Step 5: Report

Return to the user:
- The PR URL
- A summary of what was implemented
- Any deviations from the original plan and why
- Any follow-up items discovered during implementation

## Error Handling

- **Merge conflicts with main**: Rebase onto main (`git fetch origin && git rebase origin/main`), resolve conflicts, and continue.
- **Flaky tests**: If a test fails intermittently, run it 3 times. If it passes 2/3, note it as flaky in the PR description.
- **Blocked by dependency**: If the issue depends on another PR that hasn't merged, stop and tell the user. Do not stack branches unless explicitly asked.
- **Scope creep**: If you discover additional work needed beyond the plan, note it as a follow-up item rather than expanding scope. Keep the PR focused.
