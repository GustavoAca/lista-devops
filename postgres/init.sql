-- ==============================================================
-- 1. CONFIGURAÇÕES GLOBAIS E DO SISTEMA
-- ==============================================================
SET TIME ZONE 'America/Sao_Paulo';
ALTER SYSTEM SET max_connections = 100;

-- ==============================================================
-- 2. CRIAÇÃO DOS SCHEMAS E LIMPEZA
-- ==============================================================
CREATE SCHEMA IF NOT EXISTS gl_user;
CREATE SCHEMA IF NOT EXISTS gl_lista;
CREATE SCHEMA IF NOT EXISTS gl_notification;

-- Cuidado: Ao remover o public, o currentSchema no JDBC torna-se obrigatório
DROP SCHEMA IF EXISTS public CASCADE;

-- ==============================================================
-- 3. CRIAÇÃO DOS USUÁRIOS (ADMIN E APP)
-- ==============================================================
-- Administradores (Donos dos Schemas/Flyway)
CREATE USER gl_user WITH PASSWORD 'gl_user';
CREATE USER gl_lista WITH PASSWORD 'gl_lista';
CREATE USER gl_notification WITH PASSWORD 'gl_notification';

-- Usuários de Runtime (Aplicação Spring)
CREATE USER gl_user_app WITH PASSWORD 'gl_user';
CREATE USER gl_lista_app WITH PASSWORD 'gl_lista';
CREATE USER gl_notification_app WITH PASSWORD 'gl_notification';

-- ==============================================================
-- 4. ATRIBUIÇÃO DE PROPRIEDADE (OWNERSHIP)
-- ==============================================================
ALTER SCHEMA gl_user OWNER TO gl_user;
ALTER SCHEMA gl_lista OWNER TO gl_lista;
ALTER SCHEMA gl_notification OWNER TO gl_notification;

-- ==============================================================
-- 5. PERMISSÕES DE CONEXÃO E USO (HIERARQUIA POSTGRES)
-- ==============================================================
-- Nível 1: Conectar ao Banco de Dados
GRANT CONNECT ON DATABASE glaiss TO gl_user;
GRANT CONNECT ON DATABASE glaiss TO gl_user_app;
GRANT CONNECT ON DATABASE glaiss TO gl_lista;
GRANT CONNECT ON DATABASE glaiss TO gl_lista_app;
GRANT CONNECT ON DATABASE glaiss TO gl_notification;
GRANT CONNECT ON DATABASE glaiss TO gl_notification_app;

-- Nível 2: Enxergar o Schema (USAGE)
GRANT USAGE ON SCHEMA gl_user TO gl_user_app;
GRANT USAGE ON SCHEMA gl_lista TO gl_lista_app;
GRANT USAGE ON SCHEMA gl_notification TO gl_notification_app;

-- ==============================================================
-- 6. PRIVILÉGIOS DE DADOS (TABELAS E SEQUENCES)
-- ==============================================================

-- A. Privilégios para tabelas JÁ EXISTENTES (Caso você esteja corrigindo um banco já povoado)
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA gl_user TO gl_user_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA gl_user TO gl_user_app;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA gl_lista TO gl_lista_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA gl_lista TO gl_lista_app;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA gl_notification TO gl_notification_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA gl_notification TO gl_notification_app;

-- B. Privilégios PADRÃO para tabelas FUTURAS (Essencial para o Flyway)
ALTER DEFAULT PRIVILEGES FOR ROLE gl_user IN SCHEMA gl_user
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO gl_user_app;
ALTER DEFAULT PRIVILEGES FOR ROLE gl_user IN SCHEMA gl_user
    GRANT USAGE, SELECT ON SEQUENCES TO gl_user_app;

ALTER DEFAULT PRIVILEGES FOR ROLE gl_lista IN SCHEMA gl_lista
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO gl_lista_app;
ALTER DEFAULT PRIVILEGES FOR ROLE gl_lista IN SCHEMA gl_lista
    GRANT USAGE, SELECT ON SEQUENCES TO gl_lista_app;

ALTER DEFAULT PRIVILEGES FOR ROLE gl_notification IN SCHEMA gl_notification
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO gl_notification_app;
ALTER DEFAULT PRIVILEGES FOR ROLE gl_notification IN SCHEMA gl_notification
    GRANT USAGE, SELECT ON SEQUENCES TO gl_notification_app;