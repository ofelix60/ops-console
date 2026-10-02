-- Generated from workflows/l1HaLUjigAJtBQcw.json (workflow "backup-watchdog", node "Insert overdue backups")
-- by scripts/extract-queries.sh. Do not edit; change the workflow and re-export.

with expected(target) as (
  values ('backup:cajita/cajita-backend-db'),
         ('backup:glosshall-a1/glosshall-postgres')
),
overdue as (
  select e.target
  from expected e
  left join ops_checks o
    on e.target = o.target
    and o.kind = 'backup'
    and o.status = 'ok'
  group by e.target
  having max(o.checked_at) is null
      or max(o.checked_at) < now() - interval '26 hours'
)
insert into ops_checks (kind, status, target, message)
select 'backup', 'fail', overdue.target, 'no successful backup in 26h'
from overdue
where not exists (
  select 1 from ops_checks x
  where x.target = overdue.target
    and x.kind = 'backup'
    and x.status = 'fail'
    and x.acknowledged = false
)
returning id, target, message;
