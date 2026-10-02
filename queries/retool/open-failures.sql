-- Retool app → query `openFailures` (resource: ops_reviewer). 
-- {{ }} values are sent as query parameters by Retool, not pasted into the SQL.
-- Served by the partial index ops_checks_open_fail_idx (schema.sql).

select id, kind, target, checked_at, http_code, response_ms, message, details
from ops_checks
where status = 'fail'
  and acknowledged = false
  and ({{ !kindFilter.value }} or kind = {{ kindFilter.value }})
order by checked_at desc;
