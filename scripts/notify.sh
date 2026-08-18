#!/usr/bin/env bash
# Post this week's Ephemeris URL to the configured Telegram chat.
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

# Count the picks: one <section id="sNN"> per story (cover and colophon
# have their own ids, so they never match).
MAG_FILE="$REPO_DIR/magazines/${ISSUE_DATE}.html"
COUNT="$(grep -oE 'id="s[0-9]+"' "$MAG_FILE" 2>/dev/null | sort -u | wc -l | tr -d ' ')" || COUNT=0

WORDS=(zero one two three four five six seven eight nine ten eleven twelve)
if [[ "$COUNT" -eq 1 ]]; then
  PICKS_LINE="This week's pick is up:"
elif [[ "$COUNT" -ge 2 && "$COUNT" -le 12 ]]; then
  PICKS_LINE="This week's ${WORDS[COUNT]} picks are up:"
elif [[ "$COUNT" -gt 12 ]]; then
  PICKS_LINE="This week's ${COUNT} picks are up:"
else
  PICKS_LINE="This week's picks are up:"
fi

TEXT=$(cat <<EOF
☕️ *Ephemeris — ${PRETTY}*

${PICKS_LINE}
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
