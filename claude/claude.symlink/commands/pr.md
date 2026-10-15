---
description: Write a PR description
---

# pr

Ignore previous context in this conversation.

Assume this is a feature branch from either `origin/main` or `origin/master`.

Perform a `git log` to see commit messages specifically on this branch, as well as git diff to get an idea of what we changes.

Write the description per `~/.claude/skills/pr-description/SKILL.md` — read that file and follow it: four sections (What this gets us / Approach / Verify by hand / Calls worth a second opinion), prose, under 200 words. Write it to our conversation. Do not write it to a file.

If you can gleen reference materials like URLs to internal context from our conversation or elsewhere, include those.

Do not explain things that are easy to gleen in basic git/github information like files changed, tests updated, lines updated etc. Do make note of specific automated test cases we cover in tests, or what specifically should be verified by hand if anything.
