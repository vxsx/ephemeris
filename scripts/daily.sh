#!/usr/bin/env bash
# Build and publish today's Ephemeris issue.
#
# Invoked by launchd (see deploy/name.vadim.ephemeris.plist) at 08:00
# Europe/Zurich every day. Runs Claude Code in headless mode following
# daily-prompt.md. Commits + pushes + posts to Telegram are driven by
# the agent itself (see steps 6 & 7 of daily-prompt.md).

set -euo pipefail

REPO_DIR="/Users/vadim/work/ephemeris"
LOG_DIR="$REPO_DIR/.logs"
DATE_UTC="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
DATE_LOCAL="$(date +%Y-%m-%d)"
LOG_FILE="$LOG_DIR/$DATE_LOCAL.log"

mkdir -p "$LOG_DIR"

{
  echo "═══════════════════════════════════════════════════════════════"
  echo "Ephemeris daily run · started $DATE_UTC"
  echo "local: $(date) · host: $(hostname) · user: $(whoami)"
  echo "═══════════════════════════════════════════════════════════════"
} >> "$LOG_FILE"

cd "$REPO_DIR"

# Pull latest so we don't fight an out-of-date worktree.
git fetch --quiet origin main
git reset --hard origin/main --quiet
echo "✓ synced to origin/main ($(git rev-parse --short HEAD))" >> "$LOG_FILE"

# Activate the in-repo pre-commit hook (rejects duplicate / homepage URLs).
git config core.hooksPath scripts/hooks

# Restore .env — it's gitignored, not touched by the reset, but just in case.
if [[ ! -f .env ]]; then
  echo "✗ .env missing — notifier will fail" >> "$LOG_FILE"
fi

# Ping Telegram when the build fails, so a broken run (e.g. a lapsed /login,
# the way 2026-06-19/20 silently failed) surfaces the same morning instead of
# going unnoticed for days. Success notification is done by the agent itself
# (daily-prompt.md step 7). Plain text, no parse_mode — arbitrary error output
# must not break the notifier's own send. Best-effort: never aborts the script.
notify_failure() {
  local exit_code="$1"
  [[ -f "$REPO_DIR/.env" ]] && { set -a; source "$REPO_DIR/.env"; set +a; }
  [[ -n "${TELEGRAM_BOT_TOKEN:-}" && -n "${TELEGRAM_CHAT_ID:-}" ]] || {
    echo "✗ failure notify skipped — Telegram tokens missing" >> "$LOG_FILE"
    return 0
  }
  local tail_lines
  tail_lines="$(grep -v '^[[:space:]]*$' "$LOG_FILE" | tail -n 4 || true)"
  local text="⚠️ Ephemeris build failed — ${DATE_LOCAL} (exit ${exit_code}) on $(hostname)

${tail_lines}

Full log: .logs/${DATE_LOCAL}.log"
  curl -sS \
    "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" \
    --data-urlencode "text=${text}" \
    --data-urlencode "disable_web_page_preview=true" \
    >> "$LOG_FILE" 2>&1 \
    && echo "✓ Telegram notified of failure" >> "$LOG_FILE" \
    || echo "✗ failed to send failure notification" >> "$LOG_FILE"
}

# Run the agent. It will fetch sources, render the issue, commit, push, notify.
#   --print            : headless, non-interactive
#   --permission-mode  : auto-approve file/bash ops (cron has no human)
#   --model / --effort : opus + xhigh for best magazine-quality output
PROMPT="$(cat daily-prompt.md)

You are running non-interactively via launchd. Today's date is $DATE_LOCAL (Europe/Zurich). Do the full build now: fetch, select, render, commit, push, notify. Report back in ≤80 words."

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

# Keep last 30 logs.
find "$LOG_DIR" -name "*.log" -type f -mtime +30 -delete 2>/dev/null || true

exit "$EXIT"
