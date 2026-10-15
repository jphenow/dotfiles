---
name: code-review
description: Comprehensive pull request review using specialized agents, with interactive fix workflow
argument-hint: "<pr-number> [review-aspects]"
---

# Pull Request Code Review & Fix

You are an expert code reviewer conducting a thorough evaluation of PR #$ARGUMENTS. Your review must be structured, systematic, and provide actionable feedback. After review, you guide the user through fixing issues interactively.

All review output stays local — do **not** post comments, reviews, or any feedback to GitHub. Present all findings directly in the conversation for the user to triage.

## Phase 1: Preparation

### 1a. Determine Review Scope

Detect the default branch dynamically:

```bash
DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')
```

Then gather change metadata (line counts, not file content):

```bash
gh pr view $PR_NUMBER --json number,title,body,headRefName,commits,files,additions,deletions,changedFiles
gh pr diff $PR_NUMBER --name-only
gh pr checks $PR_NUMBER
```

Use `additions`/`deletions` from `gh pr view` for line-count stats. Use `--name-only` for the file list without pulling full diff content.

Identify the linked issue (look for "Closes #N" in the PR body). If found:
```bash
gh issue view <N> --json body,title
```

### 1b. Launch Parallel Preparation Agents

Launch up to 7 parallel **haiku** agents:

1. **Eligibility check** — Verify the PR is not closed or draft. If ineligible, stop and report why.
2. **Instruction files** — Find file paths (not contents) for: `CLAUDE.md`, `AGENTS.md`, `**/constitution.md`, root `README.md`, and any `README.md` in directories whose files the PR modified.
3. **Repo conventions** — Read the recently merged PRs that touched the same packages (`gh pr list --state merged --limit 20 --json number,title,mergedAt,files`, then `gh pr view <n>` / `gh pr diff <n>` for the ones whose files overlap) and report the conventions they established: the shape a given kind of output takes, how a class of condition is reported, naming and structure the reviewers there asked for. Written rules are not the only rules — a convention set by a merged PR counts even if no doc records it. Return each as "convention → the PR that established it".
4. **Change summary agents (1–4)** — Split changed files by line count across agents. Each agent runs the appropriate `git diff` for their files and returns a detailed summary: types of changes, complexity, affected classes/functions/variables, and overall description.

### 1c. PR Description

If the PR is missing a description, add one with a concise summary of changes.

---

## Phase 2: Issue Search

Based on the change summaries from Phase 1, determine which review agents are applicable, then launch up to 6 parallel agents to independently review all changes.

### When Reviewing Without Focus Areas

If you were given the diff with no focus areas, that is deliberate: named focus areas fix
the axis you reason along, and a construct cleared along one axis can still be dangerous
along another. Of each risky construct ask **"what threat model makes this dangerous?"**
rather than "is this sound?" — enumerate what else it can reach, what state it can touch
concurrently, and who else's resources match it, and only then decide. Say which threat
models you considered for each construct you cleared.

### Available Review Agents

| Agent | When to Launch |
|-------|---------------|
| **security-auditor** | Code or config changes (except purely cosmetic) |
| **bug-hunter** | Code or config changes (except purely cosmetic) |
| **code-quality** | Any code changes (business logic, infra, formatting) |
| **contracts** | Types, API, or data modeling changed |
| **test-coverage** | Test files changed |
| **historical-context** | High complexity changes or when historical context is needed |

Default: launch **all** applicable agents.

### Dimensions Every Applicable Agent Must Cover

- **Absorbed failures.** For every retry, wait, timeout, tolerate, ignore, or keep-going
  predicate in the diff: ask what it absorbs, and whether the absorbed thing is still
  counted and reported. A wait that was widened to tolerate transport errors and keeps no
  record of them turns a platform bug into "never became ready" — that is a retry masking a
  defect, and it is a finding even though the code "works". Also flag substring and prefix
  matches broad enough to swallow unrelated failures.
- **Printed operator commands.** Review any command the code prints for a human to run as
  if it will be pasted verbatim into production: does it name its targets explicitly, does
  it skip the confirmations or safety checks the real code path applies, and can it reach
  more than was intended? A convenience command that bypasses the destroy path's guards is
  blocking, not a nit.

Each agent receives:
- Full list of modified files and PR summary as context
- The PR number being reviewed
- List of instruction/guideline files from Phase 1 (CLAUDE.md, README.md, etc.)
- The conventions list from the Phase 1b repo-conventions agent

Review the change against those conventions, not only against the code as it stands. A
change that is internally correct but breaks the expectation an earlier merged PR set up is
a finding — cite the PR that established it.

Each agent returns a list of issues with the reason each was flagged (e.g., CLAUDE.md adherence, bug, historical context, etc.).

---

## Phase 3: Confidence & Impact Scoring

### 3a. Score Each Issue

For each issue from Phase 2, launch a parallel **haiku** agent that evaluates two scores:

**Confidence Score (0–100)** — How likely this is a real issue, not a false positive:

| Score | Meaning |
|-------|---------|
| 0 | False positive — doesn't hold up to scrutiny, or is pre-existing |
| 25 | Might be real, but could be false positive. Stylistic issues not called out in CLAUDE.md |
| 50 | Verified real issue, but may be a nitpick or rare in practice |
| 75 | Double-checked, very likely real and will be hit in practice. Directly impacts functionality or is explicitly mentioned in CLAUDE.md |
| 100 | Absolutely certain, will happen frequently. Evidence directly confirms it |

**Impact Score (0–100)** — Severity if left unfixed:

| Score | Level | Meaning |
|-------|-------|---------|
| 0–20 | Low | Minor code smell or style inconsistency |
| 21–40 | Medium-Low | Hurts maintainability/readability, no functional impact |
| 41–60 | Medium | Errors in edge cases, performance degradation, or hampers future changes |
| 61–80 | High | Breaks core features, corrupts data, or creates significant tech debt |
| 81–100 | Critical | Runtime errors, data loss, crashes, security breaches, or complete failure |

For CLAUDE.md-flagged issues, the agent must verify that the CLAUDE.md actually calls out the issue specifically.

### 3b. Filter Issues

Apply the progressive threshold — higher-impact issues need less confidence:

| Impact Score | Min Confidence | Rationale |
|-------------|---------------|-----------|
| 81–100 (Critical) | 50 | Worth investigating even with moderate confidence |
| 61–80 (High) | 65 | Need good confidence to avoid false alarms |
| 41–60 (Medium) | 75 | Need high confidence to justify addressing |
| 21–40 (Medium-Low) | 85 | Need very high confidence |
| 0–20 (Low) | 95 | Only if nearly certain |

**Filter out** issues below their threshold. Low impact (0–20) issues and low confidence issues should not be presented unless they are nearly certain.

### Documentation and Comment Findings

A finding about a comment, docstring, README, or PR prose is capped at **NIT** unless the
text makes a claim that is false about the code — a wrong parameter or return, a stale
contract, an example that would not run, a documented default that does not match. Those
are real and can be SHOULD_FIX or higher, because a reader acts on them.

Phrasing, ordering, tone, hedging, completeness, and "this could be clearer" do not clear
that bar. They are the findings most likely to be reversed by the next reviewer, and a
reversal costs more than the sentence was worth. When a comment is merely not how you
would have written it, leave it.

### False Positive Examples

These should score 0 confidence:
- Pre-existing issues not introduced by this PR
- Something that looks like a bug but is intentional (verified by context)

---

## Phase 4: Present Findings & Get Confirmation

### 4a. Summary Table

| # | Severity | File:Line | Description | Confidence | Impact |
|---|----------|-----------|-------------|------------|--------|
| 1 | BLOCKING | `path:42` | ... | 85 | 90 |
| 2 | SHOULD_FIX | `path:17` | ... | 75 | 55 |
| 3 | NIT | `path:8` | ... | 90 | 15 |

Categorize each issue:
- **BLOCKING**: Must fix before merge (bugs, missing error handling, security, data loss)
- **SHOULD_FIX**: Important quality issues (missing tests, poor naming, missing docs)
- **NIT**: Style, minor improvements, suggestions

### 4b. Linked Issue Compliance

If there is a linked issue, list each acceptance criterion: **DONE** / **PARTIAL** / **MISSING** / **N/A**.

### 4c. Test Coverage Assessment

- What tests exist for new/changed code?
- What test cases are missing?
- Do existing tests need updating?

### 4d. Documentation Assessment

- Are code comments adequate for complex logic?
- Does CLAUDE.md need updates (new endpoints, patterns, commands)?
- Are there unresolved TODOs/FIXMEs?

### 4e. PR Description Quality

- Is the description accurate and complete?
- If merging does not fully deploy the change (terraform with no apply in CI, new secrets,
  migrations the deploy does not run), is there a Manual deploy steps section with the
  exact commands? Per `~/.claude/skills/pr-description/SKILL.md`.
- Suggest revisions if needed.

### 4f. Open Questions

Anything requiring the owner's input, with suggested defaults.

### 4g. Gate

Ask the user:

> Which findings should I fix? Options:
> 1. **All blocking + should-fix** (recommended)
> 2. **Everything including nits**
> 3. **Let me pick** (I'll present a numbered list)
>
> Also answer any open questions above, or say "defaults are fine."

**STOP HERE.** Do not proceed until the user responds.

---

## Phase 5: Fix Workflow

Once the user confirms which issues to fix:

### 5a. Branch Setup

```bash
gh pr view $PR_NUMBER --json headRefName --jq '.headRefName'
git fetch origin <branch>
git checkout <branch>
git pull origin <branch>
```

### 5b. Fix Each Issue

Work through each confirmed finding. For each fix:

1. **Make the code change.**
2. **Run `gofmt`** on any modified Go files:
   ```bash
   gofmt -w <file.go>
   ```
3. **Run the full test suite:**
   - Go: `go build ./... && go test -v -race ./...`
   - Frontend: `cd web && npm test`
   - Both: `make ci`
4. **If tests fail**, fix the failure before committing. If the same test fails 3 consecutive times with the same error, **STOP** and report the failure.
5. **Commit** with a descriptive message:
   - Format: `<type>: <description> (#$PR_NUMBER)`
   - Types: `fix`, `test`, `docs`, `refactor`, `chore`
   - Example: `fix: add nil check for pool manager shutdown (#28)`
   - Do not commit broken code. Each commit must compile and pass tests.

### Fix Type Guidelines

**Code fixes (BLOCKING / SHOULD_FIX)**:
- Fix the issue as described in the review
- Add or update tests to cover the fix
- Add code comments for non-obvious logic

**Missing tests**:
- Add test cases identified in the review
- Follow existing test patterns in the codebase
- Ensure tests are meaningful, not just coverage padding

**Documentation**:
- Update code comments for complex logic
- Update CLAUDE.md if new endpoints, patterns, or commands were added
- Resolve TODOs/FIXMEs that belong in this PR

### 5c. Final Verification

```bash
make ci
```

If CI fails, fix and add a new commit. Do not amend previous commits.

Review what changed:
```bash
git log origin/$DEFAULT_BRANCH..HEAD --oneline
git diff origin/$DEFAULT_BRANCH..HEAD --stat
```

Confirm with the user that everything looks correct before pushing.

### 5d. Push

```bash
git push origin <branch>
```

If rejected (remote has new commits):
```bash
git pull --rebase origin <branch>
git push origin <branch>
```

### 5e. Update PR Description

If the review identified description issues or changes were significant, update it:

Write the body per `~/.claude/skills/pr-description/SKILL.md` — read that file and follow
it: four sections (What this gets us / Approach / Verify by hand / Calls worth a second
opinion), plus Manual deploy steps when merging does not fully deploy the change
(unautomated terraform, secrets, migrations), plus Context links whenever the work came
from Sentry, logs, traces, dashboards, Slack threads, or other linkable sources. Prose, under 200 words, no file table, run
through `writing-tropes` before posting.

```bash
gh pr edit $PR_NUMBER --body "$(cat <<'EOF'
<the four sections>

---
Closes #<linked-issue>
EOF
)"
```

---

## Phase 6: Report

Tell the user:
- How many findings were fixed
- Tests added or modified
- Whether the PR description was updated
- Any findings that were skipped and why
- Any follow-up items discovered during the fix process

---

## Error Handling

- **Merge conflicts with the default branch**: Note them but do NOT resolve. Suggest the user rebase separately — merge strategy is the author's decision.
- **Flaky tests**: Run up to 3 times. If passes 2/3, note as flaky in a commit message. Never dismiss a test failure as flaky without investigation.
- **Can't reproduce a finding**: Skip it, explain why, and flag for manual review.
- **Scope creep**: If you discover issues beyond the review findings, note them as follow-ups rather than fixing them. Keep changes focused on the review.
