#!/bin/zsh
# NYC Marquee daily refresh: headless Claude updates data, then deploy to Vercel.
set -u
export PATH="/Users/claytonkeener-blaha/.local/bin:/usr/local/bin:/usr/bin:/bin"
DIR="/Users/claytonkeener-blaha/Desktop/MUSIC AGENT/nyc-marquee"
LOG="$DIR/refresh.log"
cd "$DIR" || exit 1

log(){ echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG"; }
log "=== refresh started ==="

# 1. Refresh data via headless Claude
claude -p "$(cat refresh-prompt.md)" \
  --model sonnet \
  --allowedTools "WebSearch" "WebFetch" "Read" "Write" "Edit" "Glob" "Grep" "Bash" \
  >> "$LOG" 2>&1
CLAUDE_EXIT=$?
if [ $CLAUDE_EXIT -ne 0 ]; then
  log "ERROR: claude exited $CLAUDE_EXIT. If the log says 'Invalid API key', headless mode needs its own"
  log "       credential: run 'claude setup-token' once in Terminal. Keeping yesterday's deploy."
  exit 1
fi

# 2. Validate the refreshed file before deploying
awk '/<script>/{flag=1;next}/<\/script>/{flag=0}flag' marquee.html > /tmp/marquee-check.js
if ! node --check /tmp/marquee-check.js >> "$LOG" 2>&1; then
  log "ERROR: refreshed marquee.html fails JS syntax check — keeping yesterday's deploy."
  exit 1
fi
RECORDS=$(grep -c '^F(' marquee.html)
if [ "$RECORDS" -lt 40 ]; then
  log "ERROR: only $RECORDS records after refresh (suspiciously low) — keeping yesterday's deploy."
  exit 1
fi
log "validated: $RECORDS records, syntax OK"

# 3. Wrap into index.html and deploy
{
  printf '<!doctype html>\n<html lang="en">\n<meta charset="utf-8">\n<meta name="viewport" content="width=device-width, initial-scale=1">\n'
  cat marquee.html
  printf '\n</html>\n'
} > index.html

if vercel deploy --prod --yes >> "$LOG" 2>&1; then
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://nyc-marquee.vercel.app)
  log "deployed — site returned HTTP $STATUS"
else
  log "ERROR: vercel deploy failed"
  exit 1
fi
log "=== refresh complete ==="
