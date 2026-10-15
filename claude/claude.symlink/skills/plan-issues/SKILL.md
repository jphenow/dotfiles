---
name: plan-issues
description: Select a set of GitHub issues to plan — by project-board status, an explicit list of issue numbers, or freeform direction — and produce detailed implementation plans for each via the plan-issue skill. Use when starting a planning cycle for upcoming work.
disable-model-invocation: true
argument-hint: "[status <name> | issues <numbers...> | <freeform direction>] (default: Ready issues on the project board)"
---

# Plan a Batch of Issues

You are orchestrating a planning phase for a batch of GitHub issues. Your job here is **selection only**: interpret the user's direction, resolve it to a concrete list of issue numbers, then delegate the actual planning to the `plan-issue` skill.

## Step 1: Interpret the Direction

The arguments ("$ARGUMENTS") describe which issues to plan:

- **No arguments** → default: all issues with status "Ready" on the repo's GitHub Project board.
- **A project status** (e.g. `status Ready`, `status "In Design"`, or a bare status name) → all board items with that status.
- **A list of issue numbers** (e.g. `issues 123 456` or just `123 456 #789`) → exactly those issues.
- **Anything else** (a label, milestone, assignee, "everything in the billing epic", …) → translate it into the appropriate `gh` query. If the direction is ambiguous, present your interpretation and ask before proceeding.

## Step 2: Resolve to Issue Numbers

For project-board selections:

```
# If a project number was provided, use it; otherwise find the first project for this repo
gh project list --owner $(gh repo view --json owner -q .owner.login) --format json
gh project item-list <PROJECT_NUMBER> --owner <OWNER> --format json --limit 50
```

Filter items to the requested status and extract each issue's number, title, labels, and priority.

For other selections, use the matching `gh issue list` / `gh search issues` query.

Present a summary table of the selected issues (number, title, status, priority, labels). If nothing matched, say so and stop.

## Step 3: Delegate to plan-issue

Invoke the `plan-issue` skill via the Skill tool with the resolved issue numbers as its arguments (e.g. `plan-issue` with args `123 456 789`). It launches one parallel planning agent per issue, presents the plans with cross-issue conflict analysis and a recommended execution order, and waits for the user's confirmation.

Do NOT proceed to implementation. This skill is planning only.
