SET TIME ZONE 'America/Sao_Paulo';
create SCHEMA gl_user;
create SCHEMA gl_lista;
create SCHEMA gl_notification;

drop schema public;
SET TIME ZONE 'America/Sao_Paulo';


create user gl_user with password 'gl_user';
grant all privileges on schema gl_user to gl_user;

create user gl_user_app
with password 'gl_user';
grant usage on schema gl_user to gl_user_app;

create user gl_lista
with password 'gl_lista';
grant all privileges on schema gl_lista to gl_lista;

create user gl_lista_app
with password 'gl_lista';
grant usage on schema gl_lista to gl_lista_app;

create user gl_notification
with password 'gl_notification';
grant all privileges on schema gl_notification to gl_notification;

create user gl_notification_app
with password 'gl_notification';
grant usage on schema gl_notification to gl_notification_app;

-- Performance Tuning
ALTER SYSTEM
SET max_connections = 1500;
ALTER SYSTEM
SET work_mem = 16384;
ALTER SYSTEM
SET effective_cache_size = 6291456;
ALTER SYSTEM
SET maintenance_work_mem = 2097152;
