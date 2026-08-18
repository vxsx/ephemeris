#!/usr/bin/env bash
# Build and publish this week's Ephemeris issue.
#
# Invoked by launchd (see deploy/name.vadim.ephemeris.plist) on Saturdays at
# 08:00 Europe/Zurich. Runs Claude Code in headless mode following
# weekly-prompt.md. Commits + pushes + posts to Telegram are driven by
# the agent itself (see steps 6 & 7 of weekly-prompt.md).

set -euo pipefail

REPO_DIR="/Users/vadim/work/ephemeris"
LOG_DIR="$REPO_DIR/.logs"
DATE_UTC="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
DATE_LOCAL="$(date +%Y-%m-%d)"
LOG_FILE="$LOG_DIR/$DATE_LOCAL.log"

mkdir -p "$LOG_DIR"

{
  echo "═══════════════════════════════════════════════════════════════"
  echo "Ephemeris weekly run · started $DATE_UTC"
  echo "local: $(date) · host: $(hostname) · user: $(whoami)"
  echo "═══════════════════════════════════════════════════════════════"
} >> "$LOG_FILE"

cd "$REPO_DIR"

# ── Telegram helper ───────────────────────────────────────────────────────
# Plain text, no parse_mode — arbitrary error output must not break the
# notifier's own send. Best-effort: never aborts the script.
telegram_send() {
  local text="$1"
  [[ -f "$REPO_DIR/.env" ]] && { set -a; source "$REPO_DIR/.env"; set +a; }
  [[ -n "${TELEGRAM_BOT_TOKEN:-}" && -n "${TELEGRAM_CHAT_ID:-}" ]] || {
    echo "✗ Telegram notify skipped — tokens missing" >> "$LOG_FILE"
    return 0
  }
  curl -sS \
    "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" \
    --data-urlencode "text=${text}" \
    --data-urlencode "disable_web_page_preview=true" \
    >> "$LOG_FILE" 2>&1 \
    && echo "✓ Telegram notified" >> "$LOG_FILE" \
    || echo "✗ failed to send Telegram notification" >> "$LOG_FILE"
}

# Ping Telegram when the build fails, so a broken run (e.g. a lapsed /login,
# the way 2026-06-19/20 silently failed) surfaces the same morning instead of
# going unnoticed. This matters more on a weekly cadence than it did daily: a
# silent failure now costs a whole week, not a day. Success notification is
# done by the agent itself (weekly-prompt.md step 7).
notify_failure() {
  local exit_code="$1"
  local tail_lines
  tail_lines="$(grep -v '^[[:space:]]*$' "$LOG_FILE" | tail -n 4 || true)"
  telegram_send "⚠️ Ephemeris build failed — ${DATE_LOCAL} (exit ${exit_code}) on $(hostname)

${tail_lines}

Full log: .logs/${DATE_LOCAL}.log"
}

# ── Refuse to run on a dirty tree ─────────────────────────────────────────
# This used to be a bare `git reset --hard origin/main`, on the theory that the
# run needs a clean checkout. In practice it never had anything to clean: this
# job's failure mode is dying *before* it writes anything, because the agent
# does all its work and commits at the end, while the things that break it
# (session limit 2026-07-22, lapsed /login 2026-06-19/20) break it at
# invocation. On 2026-07-22 the next day's sync logged the same commit hash,
# so nothing had been left behind.
#
# So a dirty tree here almost certainly means Vadim's own uncommitted work, not
# agent leftovers — and reset --hard destroys it with no recovery path (local
# commits at least survive in the reflog; untracked files do not). Bail out and
# say so instead. Skipping an issue costs a week; losing unpushed work costs
# however long it took to write. Gitignored paths (.env, .logs/) don't count as
# dirty — `git status --porcelain` already ignores them.
git fetch --quiet origin main

DIRTY="$(git status --porcelain)"
AHEAD="$(git rev-list --count origin/main..HEAD)"

if [[ -n "$DIRTY" || "$AHEAD" -gt 0 ]]; then
  {
    echo "✗ aborting — worktree is not clean, refusing to reset --hard over it"
    if [[ "$AHEAD" -gt 0 ]]; then
      echo "  $AHEAD local commit(s) not pushed to origin/main"
    fi
    if [[ -n "$DIRTY" ]]; then
      echo "  uncommitted / untracked:"
      printf '%s\n' "$DIRTY" | sed 's/^/    /'
    fi
  } >> "$LOG_FILE"

  SUMMARY=""
  if [[ "$AHEAD" -gt 0 ]]; then
    SUMMARY="${AHEAD} unpushed commit(s)"
  fi
  if [[ -n "$DIRTY" ]]; then
    DIRTY_COUNT="$(printf '%s\n' "$DIRTY" | wc -l | tr -d ' ')"
    SUMMARY="${SUMMARY:+$SUMMARY, }${DIRTY_COUNT} changed/untracked file(s)"
  fi

  telegram_send "🟡 Ephemeris skipped ${DATE_LOCAL} — the repo has local work.

${SUMMARY}

Nothing was touched. Commit and push (or stash), then rerun with:
  launchctl kickstart -k gui/\$UID/name.vadim.ephemeris"

  echo "═══ aborted (dirty tree) at $(date -u +%Y-%m-%dT%H:%M:%SZ) ═══" >> "$LOG_FILE"
  exit 1
fi

git reset --hard origin/main --quiet
echo "✓ synced to origin/main ($(git rev-parse --short HEAD))" >> "$LOG_FILE"

# Activate the in-repo pre-commit hook (rejects duplicate / homepage URLs).
git config core.hooksPath scripts/hooks

# .env is gitignored, so the sync above never touches it — but the notifier is
# useless without it, so say so loudly if it has gone missing.
if [[ ! -f .env ]]; then
  echo "✗ .env missing — notifier will fail" >> "$LOG_FILE"
fi

# Run the agent. It will fetch sources, render the issue, commit, push, notify.
#   --print            : headless, non-interactive
#   --permission-mode  : auto-approve file/bash ops (cron has no human)
#   --model / --effort : opus + xhigh for best magazine-quality output
PROMPT="$(cat weekly-prompt.md)

You are running non-interactively via launchd. Today's date is $DATE_LOCAL (Europe/Zurich), a Saturday. Do the full build now: fetch, select, render, commit, push, notify. Report back in ≤120 words."

# `|| EXIT=$?` keeps `set -e` from aborting here, so the lines below always run
# (a bare invocation would exit the script on failure before we could notify).
EXIT=0
/Users/vadim/.local/bin/claude \
  --print \
  --permission-mode bypassPermissions \
  --model opus \
  --effort xhigh \
  --output-format text \
  "$PROMPT" >> "$LOG_FILE" 2>&1 || EXIT=$?

echo "═══ finished with exit=$EXIT at $(date -u +%Y-%m-%dT%H:%M:%SZ) ═══" >> "$LOG_FILE"

if [[ "$EXIT" -ne 0 ]]; then
  notify_failure "$EXIT"
fi

# Keep ~6 months of logs (~26 weekly runs). At the old 30-day cutoff a weekly
# cadence would retain only four issues' worth.
find "$LOG_DIR" -name "*.log" -type f -mtime +180 -delete 2>/dev/null || true

exit "$EXIT"
