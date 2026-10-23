#!/usr/bin/env bash
# Refresh the cached tropes.md from tropes.fyi, but only if the cache is stale.
# Silent no-op when fresh; never fails the caller — a bad pull keeps the old cache.
# Usage: refresh.sh [--force] [--status]
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE="$DIR/tropes.md"
URL="https://tropes.fyi/tropes-md"
MAX_AGE_DAYS="${TROPES_MAX_AGE_DAYS:-7}"

# `.no-refresh` next to this script pins the cache: keep using it, never hit the network.
[ -f "$DIR/.no-refresh" ] && { echo "tropes: refresh pinned off (.no-refresh)"; exit 0; }

age_days() { python3 - "$1" <<'PY'
import os,sys,time
p=sys.argv[1]
print(int((time.time()-os.path.getmtime(p))//86400) if os.path.exists(p) else 99999)
PY
}

AGE="$(age_days "$CACHE")"
[ "${1:-}" = "--status" ] && { echo "tropes: cache ${AGE}d old, refresh at ${MAX_AGE_DAYS}d ($CACHE)"; exit 0; }
if [ "${1:-}" != "--force" ] && [ "$AGE" -lt "$MAX_AGE_DAYS" ]; then
  exit 0   # fresh enough, stay quiet and stay offline
fi

TMP="$(mktemp -t tropes)" || exit 0
trap 'rm -f "$TMP" "$TMP.md"' EXIT

# A failed pull is never fatal: fall back to whatever is cached and say so.
fallback() {
  if [ -f "$CACHE" ]; then echo "tropes: $1, using cached copy (${AGE}d old)"
  else echo "tropes: $1, and no cached copy exists — check $URL by hand"; fi
  exit 0
}

curl -fsL --max-time 20 "$URL" -o "$TMP" 2>/dev/null || fallback "fetch failed"

# The markdown is served inside a single <pre> block; extract and sanity-check it.
if ! python3 - "$TMP" "$TMP.md" <<'PY'
import html,re,sys
raw=open(sys.argv[1],encoding='utf-8',errors='replace').read()
blocks=re.findall(r'(?s)<pre[^>]*>(.*?)</pre>',raw)
if not blocks: sys.exit("no <pre> block — page layout changed")
txt=html.unescape(re.sub(r'(?s)<[^>]+>','',blocks[0])).strip()
if not txt.startswith('# AI Writing Tropes to Avoid'): sys.exit("unexpected heading — page layout changed")
if len(txt) < 10000 or len(re.findall(r'(?m)^## ',txt)) < 20: sys.exit("content too small — page layout changed")
open(sys.argv[2],'w',encoding='utf-8').write(txt+"\n")
PY
then
  fallback "extraction failed (page layout changed)"
fi

if [ -f "$CACHE" ]; then
  BEFORE="$(grep -c '^## ' "$CACHE" 2>/dev/null || echo 0)"
  ADDED="$(comm -13 <(grep '^## ' "$CACHE" | sort) <(grep '^## ' "$TMP.md" | sort) | sed 's/^## /  + /')"
else
  BEFORE=0; ADDED=""
fi
AFTER="$(grep -c '^## ' "$TMP.md")"
mv "$TMP.md" "$CACHE"
echo "tropes: refreshed ($BEFORE -> $AFTER tropes)"
[ -n "$ADDED" ] && { echo "tropes: new since last pull:"; echo "$ADDED"; }
exit 0
