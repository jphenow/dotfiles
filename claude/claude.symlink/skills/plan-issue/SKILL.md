---
name: plan-issue
description: Produce a detailed implementation plan for one or more specific GitHub issues, given their issue numbers. Planning only — writes no code. Used directly (/plan-issue 123 456) or as the planning engine behind /plan-issues.
argument-hint: "<issue-number...>"
---

# Plan Specific Issue(s): $ARGUMENTS

You are producing detailed implementation plans for the GitHub issues listed in the arguments. This skill is planning only — do NOT write any code.

## Step 1: Resolve Issues

Parse the arguments as a list of issue numbers (space- or comma-separated, with or without a leading `#`). If no numbers were provided, ask the user which issues to plan.

Fetch each issue:

```
gh issue view <number> --json number,title,body,labels
```

If an issue doesn't exist or is closed, report it and continue with the rest.

## Step 2: Launch Parallel Planning Agents

For **each** issue, launch a Task agent (subagent_type: "Explore") in parallel with the following prompt. Do NOT write any code in this phase.

### Per-Issue Agent Prompt Template

```
You are producing a detailed implementation plan for GitHub issue #{number}: "{title}".

READ THE FULL ISSUE:
{paste the full issue body here}

EXPLORE THE CODEBASE to understand every file, interface, and test this issue touches. Map out the current state of relevant code. Use Glob and Grep extensively.

PRODUCE A PLAN with these sections:

### 1. Summary
One paragraph: what changes, why, and the user-facing impact.

### 2. Branch Name
Convention: <repo-owner>/<short-kebab-description> (e.g. jphenow/retry-backoff).
Check if the branch already exists locally or on remote. Note if so.

### 3. Files to Modify or Create
A table: | File Path | Change Description |
Include every file. Be specific about what changes in each.

### 4. Dependencies
Other issues or PRs that must land first. If none, say "None".

### 5. Implementation Steps
Numbered list of discrete, ordered steps. Each step should be one logical commit's worth of work. Include what to implement and what to test at each step.

### 6. Test Plan
- Unit tests to add or modify (with file paths)
- Integration or E2E verification steps
- Commands to run: `go test -v -race ./...`, `cd web && npm test`, `make ci`

### 7. Documentation Updates
- Code comments to add/update
- CLAUDE.md changes (new endpoints, patterns, commands)
- Any other docs

### 8. Manual Steps Required Post-Merge
Anything that cannot be automated: terraform apply, secret rotation, DNS changes, database migrations that need manual review, etc. If none, say "None".

### 9. Open Questions
List anything ambiguous in the issue that needs the owner's decision before work begins. Include design choices, naming decisions, behavior in edge cases, and any "Open Questions" from the issue body itself. For each question, suggest a default answer if you have an informed opinion.

### 10. Estimated Scope
- Small (1-2 files, <100 lines changed)
- Medium (3-6 files, 100-500 lines)
- Large (7+ files, 500+ lines)

Return the complete plan. Do NOT write any code.
```

## Step 3: Collect and Present Results

**Single issue**: present its complete plan.

**Multiple issues**: after all agents return, present a unified summary:

### Summary Table
| # | Title | Scope | Branch | Priority | Dependencies |
|---|-------|-------|--------|----------|--------------|

### Cross-Issue Conflicts
Identify files that appear in multiple plans. Flag potential merge conflicts.

### Recommended Execution Order
Based on dependencies, conflicts, and priority. Group non-conflicting issues that could theoretically run in parallel.

### All Open Questions
Grouped by issue number, with suggested defaults.

## Step 4: Wait for Confirmation

Tell the user:
> Review the plans and open questions above. Answer any questions, request changes
> to any plan, or approve them. Then either:
> - Use `/work-issues` to execute all approved issues sequentially (automated)
> - Use `/execute-issue <number>` to implement a single issue manually

Do NOT proceed to implementation. This skill is planning only.
