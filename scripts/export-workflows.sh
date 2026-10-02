#!/usr/bin/env bash
set -euo pipefail

# Fail loudly if the token isn't loaded, so the token guard below can't silently skip
: "${N8N_TOKEN:?N8N_TOKEN not set — source .env first}"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

docker compose exec -T n8n rm -rf /tmp/wf/
docker compose exec -T n8n n8n export:workflow --backup --output=/tmp/wf/
docker compose cp n8n:/tmp/wf/. "$tmp"

# Redact Slack webhook URL
sed -i.bak -E "s|https://hooks\.slack\.com/services/[A-Za-z0-9/]+|SLACK_WEBHOOK_URL_REDACTED|g" "$tmp"/*.json

# Redact email
sed -i.bak -E "s|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+|REDACTED_EMAIL|g" "$tmp"/*.json

# Drop the .bak backups before the guards — they hold pre-redaction text
rm "$tmp"/*.bak

# Guards: refuse to publish if any secret survived
if grep -rq 'hooks.slack.com/services' "$tmp"; then
  echo "✻ SLACK WEBHOOK URL STILL IN staging - NOT safe to commit" >&2
  exit 1
fi
if grep -rqF "$N8N_TOKEN" "$tmp"; then
  echo "✻ N8N_TOKEN STILL IN staging - NOT safe to commit" >&2
  exit 1
fi
if grep -rqE '@[A-Za-z0-9.-]+\.[A-Za-z]+' "$tmp"; then
  echo "✻ EMAIL STILL IN STAGING - NOT safe to commit" >&2
  exit 1
fi

# Only reached once every guard has passed
rm -rf workflows/*.json
cp "$tmp"/*.json workflows/
echo "✻ Workflows exported and scrubbed"

# Regenerate the readable SQL/JS copies from the scrubbed workflows
"$(dirname "$0")/extract-queries.sh"

