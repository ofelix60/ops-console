-- Ops Console: one queue table, written by n8n, read and acknowledged in Retool.
create table if not exists ops_checks (
  id           bigserial   primary key,
  target       text        not null,
  checked_at   timestamptz not null default now(),
  status       text        not null check (status in ('ok','fail')),
  http_code    int,
  response_ms  int,
  message      text,
  acknowledged boolean     not null default false,
  ack_by       text,
  ack_at       timestamptz
);
create index if not exists ops_checks_checked_at_idx on ops_checks (checked_at desc);
create index if not exists ops_checks_open_fail_idx  on ops_checks (checked_at desc)
  where status = 'fail' and acknowledged = false;
