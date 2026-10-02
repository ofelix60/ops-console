-- Source of truth: Retool app → health overview page, query `responseTimeSeries`

select target, checked_at, response_ms
from ops_checks
where kind = 'health'
  and status = 'ok'
  and checked_at > now() - interval '24 hours'
order by checked_at;