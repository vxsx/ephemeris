#!/usr/bin/env bash
# Post today's Ephemeris URL to the configured Telegram chat.
#
# Usage: ./scripts/notify.sh YYYY-MM-DD
#
# Reads TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID from .env (gitignored).

set -euo pipefail

ISSUE_DATE="${1:?usage: notify.sh YYYY-MM-DD}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

if [[ -f "$REPO_DIR/.env" ]]; then
  set -a; source "$REPO_DIR/.env"; set +a
fi

: "${TELEGRAM_BOT_TOKEN:?TELEGRAM_BOT_TOKEN missing (see .env.example)}"
: "${TELEGRAM_CHAT_ID:?TELEGRAM_CHAT_ID missing (see .env.example)}"

URL="https://vadim.sikora.name/ephemeris/magazines/${ISSUE_DATE}.html"

# Pretty date: "Sunday, 19 April 2026"
PRETTY="$(date -j -f '%Y-%m-%d' "$ISSUE_DATE" '+%A, %-d %B %Y' 2>/dev/null \
        || date -d "$ISSUE_DATE" '+%A, %-d %B %Y')"

TEXT=$(cat <<EOF
☕️ *Ephemeris — ${PRETTY}*

Today's ten picks are up:
${URL}
EOF
)

curl -sS --fail-with-body \
  "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" \
  --data-urlencode "text=${TEXT}" \
  --data-urlencode "parse_mode=Markdown" \
  --data-urlencode "disable_web_page_preview=false" \
  > /dev/null

echo "✓ Telegram notified: ${URL}"
