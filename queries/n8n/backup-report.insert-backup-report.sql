-- Generated from workflows/rol3USPIlF3K2yN5.json (workflow "backup-report", node "Insert backup report")
-- by scripts/extract-queries.sh. Do not edit; change the workflow and re-export.

INSERT INTO ops_checks (kind, target, status, message, details)
VALUES ('backup', 'backup:' || $1 || '/' || $2, $3, $4, $5::jsonb)
RETURNING id, target, status, message;
