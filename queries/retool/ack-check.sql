-- Source of truth: Retool app → query `ackCheck`
-- `and acknowledged = false` is the race guard: if someone else acknowledged first,
-- this matches 0 rows, and the success handler shows "already acknowledged"
-- (it checks ackCheck.data.id.length, since Retool returns SQL results column-wise).

update ops_checks
set acknowledged = true,
    ack_by = {{ current_user.email }},
    ack_at = now()
where id = {{ table1.selectedRow.id }}
  and acknowledged = false
returning id;
