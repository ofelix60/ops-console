-- Bring the original ops_checks table (commit 2230a52) up to the current schema.
-- Adds: kind column, details column, and the ack consistency check.

-- 1. Add the two new columns, nullable for now so any existing rows survive.
alter table ops_checks add column kind    text;
alter table ops_checks add column details jsonb;

-- 2. Backfill kind on existing rows, matching what was run on Neon:
--    anything targeting a backup is a backup check, everything else is health.
update ops_checks
set kind = case when target like '%backup%' then 'backup' else 'health' end;

-- 3. Now every row has a value, so require it going forward.
alter table ops_checks alter column kind set not null;

-- 4. Add the kind check constraint, named to match the schema's auto-generated name.
alter table ops_checks
  add constraint ops_checks_kind_check
  check (kind in ('health', 'backup'));

-- 5. Add the ack consistency check.
alter table ops_checks
  add constraint ack_consistency_check check (
    (acknowledged = false and ack_by is null and ack_at is null)
    or
    (acknowledged = true and ack_by is not null and ack_at is not null)
  );
