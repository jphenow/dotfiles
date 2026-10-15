---
name: work-issues
description: End-to-end workflow that plans all Ready issues from the GitHub Project board, gets approval, then sequentially implements each one -- opening PRs and handling failures automatically.
disable-model-invocation: true
argument-hint: "[project-number (default: auto-detect)]"
---

# Work All Ready Issues

You are an orchestrator. Your job is to plan all "Ready" issues, get human approval once, then
sequentially implement each issue by dispatching to subagents. You stay lean -- track progress,
handle failures, and report results. You do NOT implement code yourself.

---

## Phase 1: Discover Ready Issues

Find the GitHub Project board and extract all "Ready" items.

```bash
# Detect repo owner
OWNER=$(gh repo view --json owner -q .owner.login)

# If $ARGUMENTS is provided, use it as the project number. Otherwise find it:
gh project list --owner $OWNER --format json
# Pick the project for this repo.

# List all items and filter for status == "Ready"
gh project item-list <PROJECT_NUMBER> --owner $OWNER --format json --limit 50
```

Parse the JSON output. For each item with `"status": "Ready"`, extract:
- Issue number, title, labels, priority, full body text

If no Ready issues are found, tell the user and stop.

---

## Phase 2: Plan All Issues in Parallel

For **each** Ready issue, launch a Task agent in parallel:
- `subagent_type: "explore"`
- The agent is read-only -- it must NOT write any code

Use this prompt template for each agent (fill in `{number}`, `{title}`, `{body}`):

```
You are producing a detailed implementation plan for GitHub issue #{number}: "{title}".

FULL ISSUE BODY:
{body}

EXPLORE THE CODEBASE to understand every file, interface, and test this issue will touch.
Use Glob and Grep extensively. Map the current state of all relevant code.

PRODUCE A PLAN with these exact sections:

### 1. Summary
One paragraph: what changes, why, and the user-facing impact.

### 2. Branch Name
Convention: <repo-owner>/<short-kebab-description> (e.g. jphenow/retry-backoff).
Check if the branch already exists locally or on remote. Note if so.

### 3. Files to Modify or Create
| File Path | Change Description |
|-----------|-------------------|
Include every file. Be specific.

### 4. Dependencies
Other issues or PRs that must merge first. If none, say "None".

### 5. Implementation Steps
Numbered list of discrete steps. Each step = one logical commit.
Include what to implement AND what to test at each step.

### 6. Test Plan
- Unit tests to add/modify (with file paths)
- Integration/E2E verification steps
- Commands: go test -v -race ./... / cd web && npm test / make ci

### 7. Documentation Updates
- Code comments to add/update
- CLAUDE.md changes (new endpoints, patterns, commands)
- Any other docs

### 8. Manual Steps Required Post-Merge
Terraform apply, secret rotation, DNS, etc. If none, say "None".

### 9. Open Questions
Anything ambiguous that needs the owner's decision. For each question,
suggest a recommended default answer.

### 10. Estimated Scope
Small (<100 lines) / Medium (100-500 lines) / Large (500+ lines)

Return the complete plan. Do NOT write any code.
```

---

## Phase 3: Present Results and Wait for Approval

After all planning agents return, present a unified summary.

### 3a. Summary Table

| # | Title | Scope | Branch | Priority | Dependencies |
|---|-------|-------|--------|----------|--------------|
(one row per issue)

### 3b. Cross-Issue Conflicts

Identify files that appear in multiple plans. Flag which issues would conflict if
developed in parallel. This informs execution order.

### 3c. Recommended Execution Order

Order issues by:
1. Dependencies (prerequisites first)
2. Conflict avoidance (non-overlapping files before overlapping ones)
3. Priority (High before Medium before Low)
4. Scope (smaller first -- quick wins build momentum and reduce rebase churn)

Present the ordered list with rationale.

### 3d. All Open Questions

Group by issue number. Show the suggested default for each.

### 3e. Gate

Tell the user:

> Here are the plans for all Ready issues. Please:
> 1. Answer any open questions above (or accept the suggested defaults by saying "defaults are fine")
> 2. Adjust the execution order if you'd like
> 3. Remove any issues you don't want implemented right now
> 4. Say **"go"** to start execution
>
> I will implement each issue sequentially, pushing a PR for each. I'll skip any
> issue I can't complete after 2 attempts and report back at the end.

**STOP HERE.** Do not proceed until the user responds.

---

## Phase 4: Execute Issues Sequentially

Once the user approves, build the execution queue from the confirmed order.

### State Tracking

Maintain these data structures throughout execution:

```
QUEUE: [ {number, title, branch, plan, status: "pending"} ... ]
RESULTS: []
ATTEMPT_COUNT: { issue_number -> count }  // starts at 0
MAX_ATTEMPTS: 2
MAX_TEST_RETRIES: 3  // consecutive test failures on same error before giving up
```

### Execution Loop

For each issue in QUEUE where status == "pending":

1. **Update the progress table** (print it so the user sees current state):

   | # | Title | Status |
   |---|-------|--------|
   (pending / in_progress / success / skipped / blocked | failed)

2. **Check dependencies**: If this issue depends on another issue that is not yet
   "success" in RESULTS, move it to the end of the queue. If it's been moved to the
   end twice, mark it as "blocked" and skip.

3. **Dispatch to a Task subagent** (`subagent_type: "general"`) with this prompt:

   ```
   You are implementing GitHub issue #{number}: "{title}".

   ## Approved Plan
   {paste the full approved plan here, including answers to open questions}

   ## Instructions

   ### Branch Setup
   Run these commands:
   git fetch origin
   git checkout main
   git pull origin main
   git checkout -b {branch_name}

   If the branch already exists, create it as {branch_name}-v2 (or -v3, etc.).

   ### Implementation
   Follow the plan step by step. For each step:
   1. Make the code changes.
   2. Run tests:
      - Go: go build ./... && go test -v -race ./...
      - Frontend: cd web && npm test
      - Or: make ci
   3. If tests pass, commit:
      Format: <type>: <description> (#{number})
      Types: feat, fix, refactor, test, docs, chore
   4. If tests fail, try to fix the issue. If the same test fails 3 consecutive
      times with the same error, STOP and report the failure.

   Do not commit broken code. Each commit must compile and pass tests.

   ### Final Verification
   After all steps, run: make ci
   Review: git diff main...HEAD --stat && git log main..HEAD --oneline

   ### Push and Open PR
   git push -u origin {branch_name}

   Then open a PR:
   Write the body per ~/.claude/skills/pr-description/SKILL.md — read that file and
   follow it: four sections (What this gets us / Approach / Verify by hand / Calls worth
   a second opinion), plus Manual deploy steps when merging does not fully deploy the
   change (unautomated terraform, secrets, migrations), plus Context links whenever the
   work came from Sentry, logs, traces, dashboards, Slack threads, or other linkable
   sources. Prose, under 200 words, no file
   table, run through writing-tropes before posting.

   gh pr create --title "{title}" --body "$(cat <<'PREOF'
   <the four sections>

   ---
   Closes #{number}
   PREOF
   )"

   ### What to Return
   Return a structured response with EXACTLY this format at the end of your message:

   RESULT_STATUS: success OR failed
   RESULT_PR_URL: <url> OR none
   RESULT_ERROR: <one-line error summary> OR none
   RESULT_DEVIATIONS: <any deviations from the plan> OR none
   RESULT_FOLLOWUPS: <any follow-up items discovered> OR none
   ```

4. **Parse the subagent's response**:
   - Look for `RESULT_STATUS:` line
   - If `success`: record the PR URL, mark issue as "success", move to next
   - If `failed`: increment ATTEMPT_COUNT for this issue
     - If attempts < MAX_ATTEMPTS: move issue to end of queue for retry later
     - If attempts >= MAX_ATTEMPTS: mark as "failed", record error, move to next

5. **No-progress check**: After a full pass through the queue (all remaining items
   attempted at least once this pass), check if any PRs were opened this pass.
   If zero PRs were opened AND there are still pending/failed items, STOP the loop.
   There is no point retrying -- the remaining issues need human intervention.

### Between Issues

After each issue completes (success or failure), before moving to the next:
- Print the updated progress table
- If the completed issue modified files that overlap with upcoming issues,
  note that subsequent issues will be working on top of a changed main
  (since PRs haven't merged yet). This is expected -- each branch is
  independent off main.

---

## Phase 5: Final Report

After the execution loop finishes (all issues processed or no-progress detected),
present the final report:

### Completed
| # | Title | PR | Branch |
|---|-------|----|--------|
(all issues with status "success")

### Needs Attention
| # | Title | Error | Attempts |
|---|-------|-------|----------|
(all issues with status "failed" or "blocked")

For each failed/blocked issue, include:
- The error summary from the subagent
- What was attempted
- Suggested next step (manual fix, dependency resolution, etc.)

### Deviations from Plans
List any deviations reported by subagents.

### Follow-Up Items Discovered
List any new work items discovered during implementation.

### Manual Steps Required
Aggregate the "Manual deploy steps" sections from the PRs that were opened (PRs without
one need nothing).
Present as a checklist the user should work through after merging.

---

## Important Notes

- You are the ORCHESTRATOR. You do not write code. You dispatch, track, and report.
- Keep your own context lean. All implementation happens in subagents.
- If the user interrupts at any point, gracefully stop and print the current progress table.
- Each subagent gets a completely fresh context with the full plan baked into its prompt.
  It does not have access to your conversation history or other issues' plans.
- Subagents cannot ask the user questions. All ambiguity must be resolved in Phase 3.
  This is why the planning phase and human gate exist.
