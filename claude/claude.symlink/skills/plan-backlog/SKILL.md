---
name: plan-backlog
description: Take all "To Plan" issues from the GitHub Project board, research the codebase, ask clarifying questions, flesh out each issue into a detailed plan, update the issue bodies, and move them to "Ready" with priority.
disable-model-invocation: true
argument-hint: "[project-number (default: auto-detect)]"
---

# Plan Backlog Issues

You are an orchestrator. Your job is to take rough "To Plan" issues, research the codebase
to understand what each would involve, ask the user all clarifying questions in a single batch,
then flesh out each issue into a detailed, actionable plan and move them to "Ready" status.

You do NOT write code. You update GitHub issues and project board status.

---

## Phase 1: Discover "To Plan" Issues

```bash
OWNER=$(gh repo view --json owner -q .owner.login)

# If $ARGUMENTS is provided, use it as the project number. Otherwise find it:
gh project list --owner $OWNER --format json
# Pick the project for this repo.

# List all items and filter for status == "To Plan"
gh project item-list <PROJECT_NUMBER> --owner $OWNER --format json --limit 50
```

Parse the JSON output. For each item with `"status": "To Plan"`, extract:
- Project item ID (the `id` field -- needed later for status updates)
- Issue number, title, labels, priority, full body text

If no "To Plan" issues are found, tell the user and stop.

Present a summary:

| # | Title | Labels | Current Priority | Body Length |
|---|-------|--------|-----------------|-------------|

Then proceed to research.

---

## Phase 2: Research All Issues in Parallel

For **each** "To Plan" issue, launch a Task agent in parallel:
- `subagent_type: "explore"`
- The agent is read-only -- it must NOT modify any files

Use this prompt template (fill in `{number}`, `{title}`, `{body}`, `{labels}`):

```
You are researching GitHub issue #{number}: "{title}" to produce a detailed
implementation plan. The issue is currently in "To Plan" status and may be rough,
vague, or just a title with minimal description.

CURRENT ISSUE BODY:
{body}

LABELS: {labels}

## Your Task

### Step 1: Understand the Intent
Read the issue body carefully. Identify:
- What is the user asking for?
- What problem does this solve?
- What is the expected end state?

### Step 2: Research the Codebase
Explore the codebase to understand what this issue would actually involve.
Use Glob and Grep extensively. For each area of the codebase this issue touches:
- Read the relevant files fully
- Understand the current interfaces, data models, and patterns
- Identify what exists today vs what would need to change
- Note any related code that might be affected

### Step 3: Produce Research Output

Return these exact sections:

### 1. Intent Summary
One paragraph: what this issue is really asking for, in concrete terms.

### 2. Current State
What exists today in the codebase that's relevant. Reference specific files,
functions, interfaces, and line numbers.

### 3. Proposed Approach
How you would implement this. Be specific about:
- Architecture/design decisions that need to be made
- Key interfaces or abstractions to create or modify
- Data model changes (DB migrations, new tables/columns)
- API changes (new endpoints, modified responses)
- Frontend changes (new pages, components, UI flows)

### 4. Files Likely Affected
| File Path | What Would Change |
|-----------|------------------|

### 5. Dependencies
Other issues or PRs that should land first. If none, say "None".

### 6. Risks and Gotchas
Anything tricky, non-obvious, or likely to cause problems.

### 7. Clarifying Questions
Questions that MUST be answered before this can be planned in detail.
For each question:
- The question itself
- Why it matters (what changes based on the answer)
- Your recommended default answer based on codebase patterns

Focus on questions about:
- Design choices with multiple valid approaches
- Scope boundaries (what's in vs out)
- Behavioral decisions in edge cases
- Naming and API design preferences
- Priority relative to other work

### 8. Suggested Priority
High / Medium / Low, with a one-sentence rationale based on:
- User impact
- Technical risk if deferred
- Dependency relationships with other issues

### 9. Estimated Scope
Small (<100 lines) / Medium (100-500 lines) / Large (500+ lines)

Return the complete research. Do NOT modify any files.
```

---

## Phase 3: Present Research and Ask All Questions

After all research agents return, present a unified summary.

### 3a. Overview Table

| # | Title | Scope | Priority (suggested) | Dependencies | Questions |
|---|-------|-------|---------------------|--------------|-----------|
(one row per issue, question count per issue)

### 3b. All Clarifying Questions

Group by issue. Number them sequentially across all issues so the user can answer
by number. Include the recommended default for each.

Format:

> **Issue #{number}: {title}**
>
> **Q1.** {question}
> _Why it matters:_ {context}
> _Suggested default:_ {default}
>
> **Q2.** {question}
> ...

> **Issue #{next_number}: {title}**
>
> **Q3.** {question}
> ...

### 3c. Cross-Issue Observations

Note any patterns across issues:
- Issues that naturally group together
- Dependency chains
- Conflicting or overlapping scopes
- Issues that might be better combined or split

### 3d. Gate

Tell the user:

> Answer the questions above (or say "defaults are fine" to accept all suggested defaults).
> You can also:
> - Remove issues you don't want planned yet
> - Adjust suggested priorities
> - Add constraints or preferences I should incorporate
> - Split or combine issues
>
> Once confirmed, I'll update each issue with a detailed plan and move them to "Ready".

**STOP HERE.** Do not proceed until the user responds.

---

## Phase 4: Flesh Out and Update Issues

Once the user responds, incorporate their answers and produce the final issue bodies.

### For Each Issue

Build the updated issue body with this structure. The key principle: **preserve the
original issue content** so nothing is lost, but wrap it in a fully detailed plan.

```markdown
## Background

{Expanded background based on research. Include the current state of relevant code,
why this change matters, and any context the user or future reader needs.
Reference specific files and line numbers where relevant.}

## Objective

{Clear, concrete statement of what this issue accomplishes when done.}

## Constraints

{Any constraints, scope boundaries, or non-goals identified during research
and confirmed by the user's answers.}

## Implementation

{Detailed implementation approach. Break into phases or sections if the issue
is large. Include:
- Architecture/design decisions (with rationale from user's answers)
- Key code changes with file paths
- Data model changes
- API changes with endpoint signatures
- Frontend changes with component descriptions}

## Changes Required

| File | Change |
|------|--------|
| `path/to/file` | Description of what changes |
{Every file. Be specific.}

## Acceptance Criteria

- [ ] {Specific, testable criterion}
- [ ] {Another criterion}
{Cover: functionality, tests, documentation, edge cases}

## Sub-tasks

{Numbered list of discrete implementation steps, if the issue is large enough
to warrant breaking down. Each should be roughly one commit's worth of work.}

## Out of Scope

{Explicitly list what this issue does NOT cover, to prevent scope creep.}

## Open Questions

{Any remaining questions that can be resolved during implementation,
or "None -- all questions resolved during planning."}

---

<details>
<summary>Original issue description</summary>

{The complete original issue body, preserved verbatim}

</details>
```

### Update Each Issue

For each issue, run:

```bash
gh issue edit <number> --body "$(cat <<'EOF'
{the full updated body}
EOF
)"
```

If labels need updating based on the research (e.g., adding `infrastructure` or `discord`),
update those too:

```bash
gh issue edit <number> --add-label "label-name"
```

### Move to "Ready" with Priority

After updating the body, move each issue to "Ready" status on the project board
and set its priority. You need the project item ID (from Phase 1), the project ID,
and the field/option IDs.

Discover the IDs dynamically:

```bash
# Get project ID
gh project list --owner <OWNER> --format json
# Extract the project's id field

# Get field IDs and option IDs
gh project field-list <PROJECT_NUMBER> --owner <OWNER> --format json
# Find: Status field ID, "Ready" option ID, Priority field ID, High/Medium/Low option IDs
```

Then for each issue:

```bash
# Set status to Ready
gh project item-edit \
  --project-id <PROJECT_ID> \
  --id <ITEM_ID> \
  --field-id <STATUS_FIELD_ID> \
  --single-select-option-id <READY_OPTION_ID>

# Set priority
gh project item-edit \
  --project-id <PROJECT_ID> \
  --id <ITEM_ID> \
  --field-id <PRIORITY_FIELD_ID> \
  --single-select-option-id <PRIORITY_OPTION_ID>
```

Process issues in priority order: High first, then Medium, then Low.
Within the same priority, order by dependencies (prerequisites first) then scope (smaller first).

---

## Phase 5: Final Report

Present the results:

### Updated Issues

| # | Title | Priority | Scope | Status |
|---|-------|----------|-------|--------|
(should all show "Ready" unless an update failed)

For each issue, show:
- Link to the updated issue
- One-line summary of the plan
- Any sub-tasks count

### Priority Order Rationale

Explain the chosen priority ordering briefly. This helps the user understand
why issues are sequenced the way they are.

### Suggested Next Steps

> These issues are now in "Ready" status with detailed plans. To proceed:
> - `/work-issues` -- implement all Ready issues sequentially (automated)
> - `/plan-issues` -- review the plans again before implementing
> - `/execute-issue <number>` -- implement a single issue manually

### Issues That Need More Work

If any issue couldn't be fully planned (e.g., requires external research,
depends on decisions not yet made), list them here with what's still needed.

---

## Important Notes

- You are the ORCHESTRATOR. You do not write code. You research, ask, update, and organize.
- Keep your own context lean. All research happens in subagents.
- The original issue body is ALWAYS preserved in a collapsed `<details>` block.
  Never discard the original author's words.
- Subagents cannot ask the user questions. All clarifying questions are batched
  and presented in Phase 3. This is the only human gate.
- If an issue is already well-detailed (long body with clear acceptance criteria),
  the research agent should note that and suggest minimal changes. Don't over-plan
  issues that are already well-specified.
- When setting priority, respect any priority the user explicitly set. Only suggest
  changes -- don't override without confirmation.
