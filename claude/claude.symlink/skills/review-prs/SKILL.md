---
name: review-prs
description: Review all open PRs in parallel, surface issues and open questions, get human confirmation, then iterate through fixes for each PR -- updating code, tests, docs, PR descriptions, and pushing changes.
disable-model-invocation: true
argument-hint: "[pr-numbers... (default: all open PRs)]"
---

# Review and Fix All Open PRs

You are an orchestrator. Your job is to review all open PRs (or a specified subset),
surface findings and questions for human approval, then sequentially fix each PR by
dispatching to subagents. You stay lean -- track progress, handle failures, and report.
You do NOT write code yourself.

---

## Phase 1: Discover Open PRs

```bash
# List all open PRs with metadata
gh pr list --state open --json number,title,headRefName,author,labels,reviewDecision,isDraft,additions,deletions,changedFiles,body --limit 30
```

If `$ARGUMENTS` was provided (e.g. `28 29 33`), filter to only those PR numbers.
Otherwise, use all open non-draft PRs.

For each PR, collect: number, title, branch name, file count, additions/deletions, body.

Present a summary table:

| PR | Title | Branch | Files | +/- | Draft |
|----|-------|--------|-------|-----|-------|

Then proceed to review.

---

## Phase 2: Review All PRs in Parallel

For **each** PR, launch a Task agent in parallel:
- `subagent_type: "explore"`
- The agent is read-only -- it must NOT modify any files

Use this prompt template for each agent (fill in `{number}`, `{title}`, `{branch}`):

```
You are performing a thorough code review of PR #{number}: "{title}" on branch {branch}.

## Step 1: Gather Context

Fetch the PR diff and details:
- Run: gh pr diff {number}
- Run: gh pr view {number} --json body,commits,comments,reviews,files
- Run: gh pr checks {number} (if available)

Read the PR description body carefully. Identify the linked issue (look for "Closes #N").
If there is a linked issue, fetch it: gh issue view <N> --json body,title

## Step 2: Read the Changed Files

For each file in the PR diff, read the FULL current file on the PR branch (not just
the diff hunks). You need surrounding context to evaluate correctness.

Check out the branch first:
- Run: git fetch origin {branch}
Then read files using the Read tool from the fetched ref where needed.

## Step 3: Produce a Review

Return a review with these exact sections:

### 1. Summary
One paragraph: what this PR does, whether it achieves its stated goal.

### 2. Linked Issue Compliance
Does the PR satisfy the acceptance criteria from the linked issue?
List each acceptance criterion and mark it: DONE, PARTIAL, MISSING, or N/A.

### 3. Issues Found
Categorize each issue as:
- BLOCKING: Must fix before merge (bugs, missing error handling, security, data loss)
- SHOULD_FIX: Important quality issues (missing tests, poor naming, missing docs)
- NIT: Style, minor improvements, suggestions

For each issue:
- File path and line number(s)
- Description of the problem
- Suggested fix (be specific -- code snippet if possible)

### 4. Test Coverage Assessment
- Are there tests for the new/changed code?
- What's missing? List specific test cases that should exist.
- Do existing tests still make sense or need updating?

### 5. Documentation Assessment
- Are code comments adequate for complex logic?
- Does CLAUDE.md need updates (new endpoints, patterns, commands)?
- Does the PR description accurately describe the changes?
- Are there inline TODOs or FIXMEs that should be resolved?

### 6. PR Description Quality
- Does the Summary section accurately reflect the changes?
- Is the Changes table complete?
- Is the Testing section adequate?
- Does it have a Manual deploy steps section exactly when the change needs one (unautomated
  terraform, secrets, migrations the deploy does not run)?
- Suggest a revised PR description if needed.

### 7. Open Questions
Anything that requires the PR author's or repo owner's input to resolve.
For each question, suggest a recommended default answer.

### 8. Estimated Fix Effort
- None: PR is ready to merge as-is
- Small: <30 min of fixes (typos, minor test additions, doc updates)
- Medium: 30 min - 2 hours (missing tests, refactoring, bug fixes)
- Large: 2+ hours (significant rework needed)

Return the complete review. Do NOT modify any files.
```

---

## Phase 3: Present Reviews and Wait for Approval

After all review agents return, present a unified summary.

### 3a. Overview Table

| PR | Title | Effort | Blocking | Should Fix | Nits | Questions |
|----|-------|--------|----------|------------|------|-----------|
(one row per PR, with counts of each issue type)

### 3b. PRs Ready to Merge (No Fixes Needed)

List any PRs where the review found no blocking or should-fix issues.
Recommend merging them as-is.

### 3c. Blocking Issues by PR

For each PR with blocking issues, list the issues with file:line references
and suggested fixes. Group by PR.

### 3d. Should-Fix Issues by PR

Same format, grouped by PR.

### 3e. All Open Questions

Group by PR number. Show the suggested default for each.

### 3f. Gate

Tell the user:

> Here are the reviews for all open PRs. Please:
> 1. Answer any open questions above (or accept defaults by saying "defaults are fine")
> 2. For each PR, confirm which issues to fix (blocking + should-fix by default, nits optional)
> 3. Remove any PRs you don't want fixed right now
> 4. Say **"go"** to start fixing
>
> I will fix each PR sequentially, committing changes and pushing to the existing
> branch. I'll skip any PR I can't fix after 2 attempts and report back at the end.

**STOP HERE.** Do not proceed until the user responds.

---

## Phase 4: Fix PRs Sequentially

Once the user approves, build the fix queue from the PRs that need work.

### State Tracking

```
QUEUE: [ {number, title, branch, review, confirmed_fixes, status: "pending"} ... ]
RESULTS: []
ATTEMPT_COUNT: { pr_number -> count }
MAX_ATTEMPTS: 2
MAX_TEST_RETRIES: 3
```

### Fix Loop

For each PR in QUEUE where status == "pending":

1. **Update the progress table**:

   | PR | Title | Status |
   |----|-------|--------|
   (pending / in_progress / success / skipped / failed)

2. **Dispatch to a Task subagent** (`subagent_type: "general"`) with this prompt:

   ```
   You are fixing review findings for PR #{number}: "{title}" on branch {branch}.

   ## Review Findings to Address
   {paste the confirmed review findings -- blocking and should-fix issues,
    plus any nits the user opted into. Include file paths, line numbers,
    and suggested fixes from the review.}

   ## Answers to Open Questions
   {paste the user's answers, or "use suggested defaults" if they said so}

   ## Instructions

   ### Branch Setup
   This PR already exists. Check out its branch:
   git fetch origin {branch}
   git checkout {branch}
   git pull origin {branch}

   ### Fix Implementation
   Work through each confirmed finding. For each fix:

   1. Make the code change.
   2. Run tests:
      - Go: go build ./... && go test -v -race ./...
      - Frontend: cd web && npm test
      - Or: make ci
   3. If tests pass, commit:
      Format: fix: <description> (#{number})
      Or: test: <description> (#{number})
      Or: docs: <description> (#{number})
   4. If tests fail, try to fix. If the same test fails 3 consecutive times
      with the same error, STOP and report the failure.

   Do not commit broken code. Each commit must compile and pass tests.

   ### Specific Fix Types

   **Code fixes (BLOCKING / SHOULD_FIX)**:
   - Fix the issue as described in the review
   - Add or update tests to cover the fix
   - Add code comments if the fix involves non-obvious logic

   **Missing tests**:
   - Add the test cases identified in the review
   - Ensure tests are meaningful (not just coverage padding)
   - Follow existing test patterns in the codebase

   **Documentation fixes**:
   - Update code comments for complex logic
   - Update CLAUDE.md if the review identified missing entries
   - Fix any TODOs or FIXMEs that should be resolved in this PR

   **PR description update**:
   If the review suggested PR description changes, update it. Keep the Context
   section and its links (Sentry, logs, Slack, related issues) from the existing body:
   gh pr edit {number} --body "$(cat <<'PREOF'
   {revised PR description}
   PREOF
   )"

   ### Final Verification
   After all fixes, run: make ci
   Review what you changed: git log origin/main..HEAD --oneline

   ### Push Changes
   git push origin {branch}

   If the push is rejected (someone else pushed), pull and rebase:
   git pull --rebase origin {branch}
   Then push again.

   ### What to Return
   Return a structured response with EXACTLY this format at the end of your message:

   RESULT_STATUS: success OR failed
   RESULT_FIXES_APPLIED: <count of findings fixed>
   RESULT_FIXES_SKIPPED: <count of findings not addressed, with reasons>
   RESULT_PR_DESCRIPTION_UPDATED: yes OR no
   RESULT_TESTS_ADDED: <count of new test cases>
   RESULT_ERROR: <one-line error summary> OR none
   ```

3. **Parse the subagent's response**:
   - If `success`: mark PR as "success", record stats, move to next
   - If `failed`: increment ATTEMPT_COUNT
     - If attempts < MAX_ATTEMPTS: move to end of queue for retry
     - If attempts >= MAX_ATTEMPTS: mark as "failed", record error

4. **No-progress check**: After a full pass with zero successes and remaining
   items, STOP. The remaining PRs need human intervention.

### Between PRs

After each PR completes, print the updated progress table.

---

## Phase 5: Final Report

### Fixed
| PR | Title | Fixes Applied | Tests Added | Description Updated |
|----|-------|---------------|-------------|---------------------|
(all PRs with status "success")

### Ready to Merge
List PRs that had no issues (from Phase 3b) plus PRs that were successfully fixed.
Suggest: "These PRs are ready for final human review and merge."

### Needs Attention
| PR | Title | Error | Attempts |
|----|-------|-------|----------|
(all PRs with status "failed")

For each, include:
- What was attempted
- What specifically failed
- Suggested manual next step

### Remaining Nits Not Addressed
List any nit-level findings the user didn't opt into fixing, grouped by PR.
These are optional improvements for future consideration.

---

## Important Notes

- You are the ORCHESTRATOR. You do not write code. You dispatch, track, and report.
- Keep your own context lean. All fixes happen in subagents.
- Each subagent checks out the PR's existing branch and pushes to it. No new branches.
- Subagents cannot ask the user questions. All ambiguity must be resolved in Phase 3.
- If a PR has merge conflicts with main, the fix subagent should note it but NOT
  resolve it -- merge conflict resolution is a separate decision for the PR author.
- The review phase fetches the branch but does not check it out in the working tree.
  Multiple explore agents can read concurrently without conflicts.
