-- Generated from workflows/CSDbFHcIDKj8ic8C.json (workflow "health-check", node "Insert health check report")
-- by scripts/extract-queries.sh. Do not edit; change the workflow and re-export.

with prev as (
  select status
  from ops_checks
  where target = $1
    and kind = 'health'
  order by checked_at desc
  limit 1
)
insert into ops_checks (kind, target, status, message, details, response_ms, http_code)
values ('health', $1, $2, $3, $4::jsonb, $5, $6)
returning id, target, status, message, http_code, response_ms, (select status from prev) as prev_status;
