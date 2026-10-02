-- Source of truth: Retool app → health overview page, query healthOverview
-- TODO: paste the per-target summary query (current status, last checked,
-- uptime 24h, avg ms, p95 ms) below, and fill in the query name and date above.

with latest as (
  select distinct on (target)
         target, status, checked_at, http_code, response_ms
  from ops_checks
  where kind = 'health'
  order by target, checked_at desc
),
stats as (
  select
    target,
    count(*) filter (where status = 'ok')::float / count(*) * 100 as uptime_pct,
    avg(response_ms) as avg_ms,
    percentile_cont(0.95) within group (order by response_ms) as p95_ms
  from ops_checks
  where kind = 'health'
    and checked_at > now() - interval '24 hours'
  group by target
)
select
  l.target,
  l.status            as current_status,
  l.checked_at        as last_checked,
  round(s.uptime_pct::numeric, 1)  as uptime_24h_pct,
  round(s.avg_ms::numeric, 0)      as avg_ms,
  round(s.p95_ms::numeric, 0)      as p95_ms
from latest l
left join stats s on l.target = s.target
order by l.target;