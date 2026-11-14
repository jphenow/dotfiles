# Review Angles and Depth Tiers

Shared by `code-review`, `ship-issue`, and `review-prs`. A reviewer grades the change first,
then decides how deep each angle goes. Every angle is always at least *screened*; only the
ones the tier calls for get a dedicated deep pass.

The reviewer grades the diff itself. The orchestrator never passes a tier or a list of
triggered angles in, so an unsteered pass stays unsteered.

---

## 1. Grade the change

Work out two things from `git diff` / `gh pr diff`: which angle **triggers** fire (each
angle below lists its own), and the **size** of the change.

| Tier | Name | When |
|------|------|------|
| 0 | Trivial | Docs, comments, formatting, test-only, or dev-only tooling, and no trigger fires. |
| 1 | Standard | Ordinary logic change; no trigger fires. |
| 2 | Elevated | One or two angles trigger, **or** the diff is large (roughly 400+ changed lines of non-test code, or it spans several components/services). |
| 3 | High | Three or more angles trigger, **or** any change a plain revert cannot undo (destructive or irreversible migration, data rewrite or format change on disk or on the wire, external side effects like charges, emails, or deletions), **or** an auth/authz change that applies to every user at once. |

Size can raise the tier by at most one step, and only from 1 to 2. A big diff with no
triggers is still mostly bug-hunting, not security work.

If unsure between two tiers, take the higher one. Use the language of the files changed, not
the PR title. "Refactor" PRs often move auth or serialization code around.

## 2. Depth per tier

| Tier | Screen (one line per angle: N/A, or what you checked) | Deep pass |
|------|------|------|
| 0 | One combined line: "no angle triggers" or the exception | None |
| 1 | Every angle | None |
| 2 | Every angle | Each **triggered** angle |
| 3 | Every angle | **Every** angle, triggered or not, plus historical context on the touched code |

**Deep pass** means its own reviewer with that angle's brief below. When you can launch agents,
that is one agent per deep angle, run in parallel with the other review agents. When you
cannot (you are a subagent without the Agent tool, or a read-only explore agent), do the
deep passes yourself, one after another. Write each as its own section, and re-read the
diff from the angle's point of view before starting each one. Never merge the deep passes
into a single "looked at security and risk" paragraph.

A screen that turns up a real concern promotes that angle to a deep pass, whatever the tier.

## 3. Report the grade

Every review that uses this file must output:

```
REVIEW_TIER: <0-3> (<triggered angles, or "none">; <size note if it moved the tier>)
REVIEW_ANGLES:
  security:      <deep | screened: what you checked | n/a>
  version-skew:  ...
  reversibility: ...
  durability:    ...
  operability:   ...
  limits:        ...
  test-honesty:  ...
```

Findings from any angle go in the normal findings list, at their real severity. The PR
description's **Security** and **Risk** sections (`pr-description`) should agree with this
grade: if a Tier 3 PR has no Risk section, or a Tier 0 PR claims High risk, flag it.

---

## Angles

Each angle has **triggers** (when it fires) and a **brief** (what the deep pass checks). The
brief is the prompt for that angle's agent. Pass it in together with the shared context
`code-review` already gives every agent.

### security (the `security-auditor` agent)

**Triggers:** authentication or sessions; authorization or anything that scopes data to a user,
org, or tenant; secrets, tokens, keys, or credentials; parsing or rendering untrusted input
(HTTP bodies, headers, webhooks, uploads, archives, user markup, filenames, URLs); building
SQL, shell commands, paths, regexes, or templates from input; crypto or randomness used for
security; new dependencies or version bumps of network, crypto, or parsing libraries;
outbound requests to URLs that come from input; CORS, CSP, cookie, or TLS settings; IAM, file
modes, or container privileges; logging near request data; untrusted text that reaches an
LLM prompt or an agent that has tools.

**Brief.** Assume an attacker who controls every input the diff reads. For each one, trace
where it lands.

- **Authn/authz.** Every new endpoint, handler, RPC, or job checks *who* is calling and
  *whether they may touch this specific resource*. A valid token is not proof of access to
  this resource. Look for IDs taken from the request and used without an ownership check
  (IDOR), checks done at list time but not at fetch or update time, and admin-only paths
  reachable by changing a parameter.
- **Tenant isolation.** Every query, cache key, storage path, bucket prefix, queue name, and
  lock is scoped to the tenant. Ask "whose resources besides the intended ones match this
  selector?" A prefix match or LIKE on a tenant id is a finding.
- **Injection.** SQL, shell, path traversal (`..`, absolute paths, symlinks, archive entries),
  template/HTML (XSS), header/CRLF, regex DoS, deserialization of untrusted data, SSRF
  (requests to input-controlled hosts, including redirects and internal metadata addresses).
- **Secrets.** Nothing secret is logged, put in an error message, placed in a URL, sent to the
  client, written to world-readable files, or committed (including in test fixtures).
  Comparisons of secrets are constant-time. New secrets arrive through the existing secret
  mechanism, not env defaults or config files.
- **Crypto.** No home-made constructions. Randomness for tokens comes from a CSPRNG.
  Signatures and MACs are verified before the payload is used. Expiry is enforced.
- **Fail closed.** On error, timeout, or missing config, access is denied, not allowed.
  Feature flags that gate a check default to *checking*.
- **Dependencies.** New packages are well known and maintained, and pinned in the lockfile.
  No `replace` or fork pointing at a personal repo. No install scripts doing anything surprising.
- **Agent and LLM input.** Text from issues, comments, PR bodies, web pages, files, or tool
  output that reaches a model prompt is treated as data. Check whether it can change what an
  agent with tools does, or decide which tools it calls and with what arguments. Can it widen
  the agent's spec?
- **Operator surfaces.** Printed commands, admin scripts, and debug endpoints apply the same
  guards as the real code path, and are not reachable in production by accident.

State each threat you considered and why it does not apply. "No security issues" with no
reasoning is not a deep pass.

### version-skew (mixed versions during and after rollout)

**Triggers:** API, RPC, or wire-format changes; serialized data (JSON fields, protobuf,
database columns, cache entries, files on disk) read by more than one version; config or flag
schema; clients that update on their own schedule (CLIs, SDKs, mobile, agents, long-running
workers or VMs); rolling, blue/green, or hot-code deploys; message or queue payloads.

**Brief.** During a deploy, and for a long time after it for clients, old and new code run
side by side.

- Old client → new server and new client → old server both still work, or fail with a clear
  error rather than misbehaving. Removed or renamed fields, changed enum values, and new
  required fields are the usual breakers.
- Data written by the new version can be read by the old one (it may be rolled back to), and
  the other way round.
- In-flight work survives the cutover: queued jobs, open connections, persisted state machines,
  and cached entries in the old shape.
- On hot-upgrade runtimes, state shape changes have a migration path, and cross-node calls
  don't reference code that only exists on one side.
- If skew is unavoidable, the order of deploys (server first, then clients) is written in
  **Manual deploy steps**.

### reversibility (what a revert can and cannot undo)

**Triggers:** schema or data migrations; backfills; data written in a new format; deletes or
overwrites; external side effects (emails, charges, webhooks, third-party API writes,
infrastructure changes); removing a feature flag or a compatibility path.

**Brief.** Assume the change ships and turns out to be wrong a day later.

- Does `git revert` + deploy restore the previous behaviour completely? If not, name exactly
  what stays changed.
- Migrations: can they be undone? Is the forward migration safe to run twice, and safe to run
  while the old code is still serving (no locking a hot table, no dropping a column the old
  code still reads)?
- Destructive steps happen only after the new path has been proven: expand, migrate, then
  contract, rather than everything in one PR.
- External side effects can't be recalled. Are they guarded by a flag, a dry run, or a staged
  rollout?
- If the honest answer is "a revert doesn't fix it", the PR's Risk section must say **High**
  and say what would lower it.

### durability (crash consistency and data integrity)

**Triggers:** writing files, blocks, or objects; fsync, flush, or rename; database transactions
or multi-statement writes; queues and outboxes; caches that can go stale; multi-step operations
across stores (DB + object store, local disk + remote); checksums; compaction, GC, or cleanup
of stored data.

**Brief.** Pull the plug at every line.

- A crash or kill between any two steps leaves state that the next start can detect and
  repair, not silently wrong state. Write the new thing, make it durable, *then* point at it
  or delete the old one.
- fsync/flush happens where durability is claimed, including on the parent directory after a
  rename. Errors from close, flush, and fsync are checked.
- Remote writes: partial success, retries that duplicate, eventual consistency on
  read-after-write, and a timeout that actually succeeded are all handled. Idempotency keys or
  conditional writes where duplicates would hurt.
- Transactions cover the whole invariant. No read-modify-write races between concurrent
  writers. Locks are released on every path.
- Cleanup, GC, and compaction can never delete something still referenced, including by a
  writer that is in flight right now.
- Integrity is checked where data crosses a trust or storage boundary (checksums verified on
  read, not only computed on write).

### operability (will we know, and can we act)

**Triggers:** new failure modes; error handling, retries, timeouts, or fallbacks; background
jobs, loops, or daemons; changes to logging, metrics, alerts, or health checks; behaviour behind
feature flags; anything on-call would debug.

**Brief.**

- When this breaks in production, what tells us? A metric, log line, alert, or error report
  that names the cause, not just a generic 500 or a silent skip.
- Retries, fallbacks, and "keep going" branches still count and report what they absorbed (see
  "Absorbed failures" in `code-review`).
- Does it fail open or closed, and is that the right choice for this path?
- Health and readiness checks still mean something: they neither pass while the new path is
  broken nor flap because of it.
- Logs have enough context (ids, not payloads) to trace one request, and don't explode in
  volume on a hot path.
- Can it be turned off without a deploy? (Flag, config.) If not, should it be?

### limits (resources, fan-out, cost)

**Triggers:** loops over collections from input or storage; fan-out to other services; new
outbound calls; retries or polling; caches; concurrency (goroutines, tasks, pools); queries
without limits; anything billed per request, byte, or second.

**Brief.**

- Every loop, query, and batch has a bound that holds for the largest real tenant, not just test
  data. Pagination is used where lists can grow.
- Fan-out and concurrency are capped. A slow dependency can't cause unbounded queued work or
  memory growth.
- Retries have backoff, jitter, and a cap. Many clients retrying together can't overwhelm the
  dependency.
- Respect the rate limits of APIs you call. Handle 429/backpressure.
- Per-request cost (third-party calls, object-store requests, egress, model tokens) is
  reasonable at production volume. Say the rough multiplier if it changes.
- Timeouts exist on every network call and are shorter than the caller's own timeout.

### test-honesty (do the tests prove the change)

**Triggers:** any behaviour change that comes with tests, and any bug fix (with or without
tests).

**Brief.**

- For each new or changed test: would it fail if the change were reverted? Reason it through
  against the pre-change code (`git show origin/main:<file>`). A test that passes either way
  proves nothing. Do not modify the working tree to check.
- Bug fixes come with a test that reproduces the bug, unless reproducing it is truly
  impractical; if so, the PR says why.
- Mocks don't stub out the very thing being tested. Assertions check outcomes, not just "no
  error". Errors and edge paths are exercised, not only the happy path.
- No tests weakened, skipped, or deleted to make the suite pass without a stated reason.
- Flaky-by-design constructs (sleeps, wall-clock time, ordering of maps or goroutines) are
  flagged.
