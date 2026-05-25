#!/usr/bin/env bash
# Validate magazine HTML before commit:
#   1. Every read-on URL must not already appear in published-urls.txt as
#      committed to HEAD (i.e. shipped in a prior issue). Today's appended
#      URLs are expected in the working copy, so we check against HEAD's
#      version, not the staged one.
#   2. Every read-on URL must have a non-empty path. Bare-domain links
#      (e.g. https://v0.app/) point at marketing homepages, not articles,
#      and have shipped as duplicates before — reject them.
#
# Usage: scripts/check-magazine.sh <magazine.html> [...]
# Exits non-zero with a list of offending URLs.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

if [[ $# -eq 0 ]]; then
  echo "usage: $0 <magazine.html> [...]" >&2
  exit 2
fi

PREV_LEDGER="$(git show HEAD:published-urls.txt 2>/dev/null || true)"

fail=0
for file in "$@"; do
  if [[ ! -f "$file" ]]; then
    echo "✗ $file: not found" >&2
    fail=1
    continue
  fi

  urls="$(grep -oE 'class="read-on"[^>]*href="[^"]+"' "$file" \
          | grep -oE 'https?://[^"]+' || true)"
  [[ -z "$urls" ]] && continue

  while IFS= read -r url; do
    [[ -z "$url" ]] && continue
    canon="$(printf '%s\n' "$url" | scripts/canonical-url.sh)"
    path="$(printf '%s' "$canon" | sed -E 's|^https?://[^/]+||')"

    if [[ -z "$path" || "$path" == "/" ]]; then
      echo "✗ $file: homepage URL not allowed → $canon" >&2
      fail=1
    fi

    if [[ -n "$PREV_LEDGER" ]] && grep -Fxq "$canon" <<<"$PREV_LEDGER"; then
      echo "✗ $file: already shipped in a prior issue → $canon" >&2
      fail=1
    fi
  done <<<"$urls"
done

if (( fail )); then
  echo "" >&2
  echo "Magazine check failed. Replace the URLs above with primary-source links" >&2
  echo "or drop the story, then re-stage." >&2
  exit 1
fi
