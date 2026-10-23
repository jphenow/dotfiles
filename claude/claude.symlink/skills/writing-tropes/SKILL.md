---
name: writing-tropes
description: Check prose against the catalog of AI writing tells at tropes.fyi before delivering it. Use when writing or editing anything a human will read as prose -- PR and issue bodies, commit messages longer than a line, docs, READMEs, Slack or standup posts, nudges and drafted messages, reports, summaries, blog or marketing copy -- and when asked to make writing sound less like AI. Not for code, code comments, config, or short factual answers in the terminal.
---

# Writing Tropes

A catalog of ~49 cataloged AI writing tells lives in `tropes.md` next to this file
(source: [tropes.fyi](https://tropes.fyi) by ossama.is). Use it to check prose before it
goes out, not to write timidly.

## How to use it

1. **Refresh the cache** (silent no-op unless it is more than 7 days old, and never blocks
   on a failed pull):

   ```bash
   bash ~/.claude/skills/writing-tropes/refresh.sh
   ```

2. **Draft normally.** Do not write with the list in front of you — that produces stilted
   prose that dodges tells and says nothing.

3. **Then read `tropes.md` and pass over the draft**, if the piece is substantial: a PR
   body, a doc, an issue, a post, anything more than a few sentences. For short prose the
   list below is enough. Fix what actually fires; leave what does not.

## The tells that fire most often

These are the `consistent` and `rising` entries — the ones worth knowing by heart:

- **Negative parallelism** — "It's not X, it's Y." The single most common tell.
- **Em-dash addiction** — 2-3 per piece is human; more is not.
- **Short punchy fragments** — one-sentence paragraphs for manufactured emphasis.
- **Rule of three** — every list padded to exactly three items.
- **Grandiose stakes inflation** — small things framed as consequential.
- **Invented concept labels** — naming a thing to make it sound like a framework.
- **"Quietly" and other magic adverbs** — quietly, meaningfully, genuinely, actually.
- **The Tie-Back** — closing by calling back to the opening image.
- **Vague attributions** — "many argue", "it's often said".
- **Excessive enumeration** — bulleting what should be a sentence.
- **Fractal summaries** — summarizing at every level, including what was just said.
- **Signposted / never-ending conclusion** — announcing the ending, then ending twice.
- **Collaborative communication** — "Great question!", "Let's dive in."
- **Title Case Headings** and **bold-first bullets** as reflex formatting.
- **Reasoning leak** — narrating what the writing is about to do instead of doing it.

`tropes.md` has the rest, each with three examples of the pattern to avoid.

## Judgment

Any of these once is fine; the problem is several together or one repeatedly. Do not
mangle a sentence that is clear and true just because it pattern-matches — a real "not X
but Y" contrast that carries information stays. Prefer cutting to rewriting: most of these
tells sit on sentences that were not earning their place anyway.

Never mention this skill or the trope names in delivered prose. The output is the writing.

## Turning it off

- **Stop the weekly network pull, keep the doc:** `touch ~/.claude/skills/writing-tropes/.no-refresh`
- **Only on request** (no automatic triggering; `/writing-tropes` still works): add
  `disable-model-invocation: true` to this file's frontmatter.
- **Rip it out completely:** `rm -rf ~/.claude/skills/writing-tropes` — nothing outside
  this directory was modified, so there is no other cleanup.
