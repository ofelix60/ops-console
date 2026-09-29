-- Ops Console: one queue table, written by n8n, read and acknowledged in Retool.
create table if not exists ops_checks (
  id           bigserial   primary key,
  target       text        not null,
  checked_at   timestamptz not null default now(),
  status       text        not null check (status in ('ok','fail')),
  kind         text        not null check (kind in ('health','backup')),
  http_code    int,
  response_ms  int,
  message      text,
  details      jsonb,
  acknowledged boolean     not null default false,
  ack_by       text,
  ack_at       timestamptz,

  constraint ack_consistency_check check (
    (acknowledged = false and ack_by is null and ack_at is null)
    or
    (acknowledged = true and ack_by is not null and ack_at is not null)
  )
);
create index if not exists ops_checks_checked_at_idx on ops_checks (checked_at desc);
create index if not exists ops_checks_open_fail_idx  on ops_checks (checked_at desc)
  where status = 'fail' and acknowledged = false;
create index if not exists ops_checks_target_checked_at_idx
  on ops_checks (target, checked_at desc);

