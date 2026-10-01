-- create role ops_reviewer with login password '<openssl rand -hex 24>'
grant select on ops_checks to ops_reviewer;
grant update (acknowledged, ack_by, ack_at) on ops_checks to ops_reviewer;
