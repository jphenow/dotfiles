---
name: fix-pr
description: Review a single PR, present findings, then interactively fix issues -- updating code, tests, docs, and the PR description. Commits and pushes to the existing branch.
disable-model-invocation: true
argument-hint: "<pr-number>"
---

# Review and Fix PR #$ARGUMENTS

You are reviewing and fixing a single pull request interactively.

## Step 1: Gather Context

```bash
gh pr view $ARGUMENTS --json number,title,body,headRefName,commits,files,comments,reviews,additions,deletions,changedFiles
gh pr diff $ARGUMENTS
gh pr checks $ARGUMENTS
```

Identify the linked issue (look for "Closes #N" in the PR body). If found:
```bash
gh issue view <N> --json body,title
```

Read the full issue body to understand acceptance criteria.

## Step 2: Review the Code

Check out the PR branch:
```bash
git fetch origin <branch>
git checkout <branch>
git pull origin <branch>
```

For each changed file in the PR diff, read the FULL file (not just diff hunks)
to understand surrounding context.

Produce a review with these sections:

### Linked Issue Compliance
List each acceptance criterion from the linked issue. Mark each: DONE / PARTIAL / MISSING / N/A.

### Issues Found
Categorize as BLOCKING, SHOULD_FIX, or NIT. For each:
- File path and line number(s)
- Description of the problem
- Suggested fix (specific code snippet when possible)

### Test Coverage
- What tests exist for the new/changed code?
- What test cases are missing?

### Documentation
- Are code comments adequate?
- Does CLAUDE.md need updates?
- Are there unresolved TODOs/FIXMEs?

### PR Description Quality
- Is the description accurate and complete?
- If merging does not fully deploy the change (terraform with no apply in CI, new secrets,
  migrations the deploy does not run), is there a Manual deploy steps section with the
  exact commands? Per `~/.claude/skills/pr-description/SKILL.md`.
- Suggest revisions if needed.

### Open Questions
Anything requiring the owner's input. Suggest defaults.

Present the review and ask:
> Which findings should I fix? Options:
> 1. **All blocking + should-fix** (recommended)
> 2. **Everything including nits**
> 3. **Let me pick** (I'll present a numbered list)
>
> Also, answer any open questions above or say "defaults are fine."

**Wait for the user's response before proceeding.**

## Step 3: Fix the Issues

Work through each confirmed finding. For each fix:

1. **Make the code change.**
2. **Run relevant tests:**
   - Go: `go build ./... && go test -v -race ./...`
   - Frontend: `cd web && npm test`
   - Both: `make ci`
3. **Commit** with a descriptive message:
   - Format: `<type>: <description> (#$ARGUMENTS)`
   - Types: `fix`, `test`, `docs`, `refactor`, `chore`
   - Example: `fix: add nil check for pool manager shutdown (#28)`
4. **If tests fail**, fix the issue before committing. Do not commit broken code.
5. **Create a checkpoint** after each successful commit (if the Sprite skill is available).

### Fix Types

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

**PR description**:
If the review identified description issues, update it:
Write the body per `~/.claude/skills/pr-description/SKILL.md` — read that file and follow
it: four sections (What this gets us / Approach / Verify by hand / Calls worth a second
opinion), plus Manual deploy steps when merging does not fully deploy the change
(unautomated terraform, secrets, migrations), plus Context links whenever the work came
from Sentry, logs, traces, dashboards, Slack threads, or other linkable sources. Prose, under 200 words, no file table, run
through `writing-tropes` before posting.

```bash
gh pr edit $ARGUMENTS --body "$(cat <<'EOF'
<the four sections>

---
Closes #<linked-issue>
EOF
)"
```

## Step 4: Final Verification

```bash
make ci
```

If CI fails, fix and add a new commit. Do not amend previous commits.

Review the changes:
```bash
git diff origin/main..HEAD --stat
git log origin/main..HEAD --oneline
```

Confirm with the user that everything looks correct before pushing.

## Step 5: Push

```bash
git push origin <branch>
```

If rejected (remote has new commits), pull and rebase:
```bash
git pull --rebase origin <branch>
git push origin <branch>
```

## Step 6: Report

Tell the user:
- How many findings were fixed
- Tests added or modified
- Whether the PR description was updated
- Any findings that were skipped and why
- Any follow-up items discovered

## Error Handling

- **Merge conflicts with main**: Note them but do NOT resolve. Suggest the user
  rebase the branch separately. Merge strategy is the author's decision.
- **Flaky tests**: Run 3 times. If passes 2/3, note as flaky in a commit message.
- **Can't reproduce a finding**: Skip it, explain why, and flag for manual review.
- **Scope creep**: If you discover issues beyond the review findings, note them
  as follow-ups rather than fixing them. Keep changes focused on the review.
