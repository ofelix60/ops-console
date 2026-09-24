create role ops_writer with login password LOGIN;
grant select, insert on ops_checks to ops_writer;
