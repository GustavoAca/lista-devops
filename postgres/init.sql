create SCHEMA att_user;
create SCHEMA att_lista;

drop schema public;

create user att_user with password 'user_ddl_SaintBier';
grant all privileges on schema att_user to att_user;

create user att_user_APP
with password 'user_SaintBier';
grant usage on schema att_user to att_user_APP;

create user att_lista
with password 'lista_ddl_SaintBier';
grant all privileges on schema att_lista to att_lista;

create user att_lista_APP
with password 'lista_SaintBier';
grant usage on schema att_lista to att_lista_APP;

-- Performance Tuning
ALTER SYSTEM
SET max_connections = 1500;
ALTER SYSTEM
SET work_mem = 16384;
ALTER SYSTEM
SET effective_cache_size = 6291456;
ALTER SYSTEM
SET maintenance_work_mem = 2097152;
