# ops-console

An internal operations console: scheduled health checks and backup-job webhooks land in
PostgreSQL through **n8n**, and a **Retool** app turns that table into a queue an operator can
filter, inspect, and acknowledge.

<!-- TODO after building:
     - the flow diagram
     - why the backup webhook exists (backup.sh already exits non-zero; nothing was watching)
     - 2-3 Retool screenshots in docs/  (redact your email and DB host)
     - what you'd add next: alert dedupe, per-target thresholds, row retention
-->

## Layout
| Path | What |
|---|---|
| `schema.sql` | The `ops_checks` queue table |
| `compose.yaml` | Local self-hosted n8n |
| `workflows/` | n8n workflow exports (JSON) |
| `docs/` | Screenshots of the Retool app |

## Setup
```bash
cp .env.example .env        # fill in; .env is gitignored
docker compose up -d n8n    # http://localhost:5678
psql "$DATABASE_URL" -f schema.sql
```
