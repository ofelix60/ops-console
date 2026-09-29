#! /usr/bin/env bash
set -euo pipefail

docker compose exec n8n n8n export:workflow --backup --output=/tmp/wf/
docker compose cp n8n:/tmp/wf/. workflows/

# Redact Slack webhook URL
sed -E -i '' "s|https://hooks\.slack\.com/services/[A-Za-z0-9/]+|SLACK_WEBHOOK_URL_REDACTED|g" workflows/*.json

# Redact name and email
sed -E -i '' "s|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+|REDACTED_EMAIL|g" workflows/*.json
sed -i '' "s|Oscar Felix|REDACTED|g" workflows/*.json

if grep -r 'hooks.slack.com/services' workflows; then
  echo "✻ SLACK WEBHOOK URL STILL IN workflows/ - NOT safe to commit" >&2
  exit 1
fi

echo "✻ Workflows exported and scrubbed"

