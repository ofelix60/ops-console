-- Add a composite index to make "most recent check for a given target" instant.
-- The 6b state-change logic looks up each target's latest row every 5 minutes;
-- without this, that's a sequential scan that grows with the table.
-- Column order matters: target (equality filter) first, then checked_at desc
-- (the ordering), so Postgres can jump to a target and read its newest row directly.
create index if not exists ops_checks_target_checked_at_idx
  on ops_checks (target, checked_at desc);
