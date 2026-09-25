-- create role ops_writer with login password '<openssl rand -hex 24>';
grant select, insert on ops_checks to ops_writer;
grant usage on sequence ops_checks_id_seq to ops_writer;
