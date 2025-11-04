# Projeto Lista de Compra - DevOps

Este repositório contém a configuração de infraestrutura e orquestração para o projeto "Lista de Compra", que é uma aplicação baseada em microserviços. Utiliza Docker e Docker Compose para gerenciar os diversos serviços, incluindo bancos de dados, cache, ferramentas de monitoramento e os próprios microserviços da aplicação.

## Arquitetura

O projeto segue uma arquitetura de microserviços, onde cada funcionalidade principal é encapsulada em um serviço independente. A orquestração desses serviços é feita via Docker Compose, garantindo um ambiente de desenvolvimento e execução consistente.

Os principais componentes da arquitetura são:

*   **Serviços de Infraestrutura**: PostgreSQL (banco de dados), Redis (cache), Elasticsearch (busca e análise de logs), Logstash (coleta e processamento de logs) e Kibana (visualização de logs).
*   **Serviços da Aplicação**:
    *   `discovery`: Servidor Eureka para descoberta de serviços.
    *   `gateway`: Gateway de API para roteamento e segurança das requisições.
    *   `users`: Microserviço responsável pela gestão de usuários.
    *   `lista`: Microserviço responsável pela gestão de listas de compra.
    *   `notification`: Microserviço responsável pelo envio de notificações.

## Serviços

### `postgres`

*   **Descrição**: Banco de dados PostgreSQL para persistência de dados dos microserviços.
*   **Configuração**:
    *   Construído a partir de um `Dockerfile` local que adiciona o `init.sql` para inicialização do banco.
    *   `init.sql`: Cria esquemas (`gl_user`, `gl_lista`, `gl_notification`), usuários (`gl_user`, `gl_lista`, `gl_notification`) e aplica configurações de performance e segurança.
    *   **Usuário/Senha Padrão**: `glaiss`/`PPgg123` (para o banco principal).
    *   **Porta**: `5432` (mapeada para `5432` no host).

### `redis`

*   **Descrição**: Servidor Redis para cache e armazenamento temporário de dados.
*   **Configuração**:
    *   Imagem: `redis:latest`
    *   **Porta**: `6379` (mapeada para `6379` no host).
    *   **Volume**: Persiste dados em `./.data/duducp/RedisData`.

### `elasticsearch`

*   **Descrição**: Motor de busca e análise distribuído, utilizado para armazenar logs e dados de monitoramento.
*   **Configuração**:
    *   Imagem: `docker.elastic.co/elasticsearch/elasticsearch:8.10.2`
    *   **Portas**: `9200` (HTTP) e `9300` (TCP) (mapeadas para o host).
    *   **Ambiente**: Configurado como single-node, segurança desabilitada (`xpack.security.enabled=false`).
    *   **Volume**: Persiste dados em `elasticsearch_data`.

### `logstash`

*   **Descrição**: Pipeline de processamento de dados, coleta logs via TCP e os envia para o Elasticsearch.
*   **Configuração**:
    *   Imagem: `docker.elastic.co/logstash/logstash:8.10.2`
    *   **Portas**: `5000` (entrada TCP para logs) e `9600` (API de monitoramento).
    *   **Volume**: Monta `logstash.conf` como pipeline de configuração.
    *   `logstash.conf`: Configurado para receber logs JSON via TCP na porta 5000 e indexá-los no Elasticsearch.

### `kibana`

*   **Descrição**: Ferramenta de visualização e exploração de dados para o Elasticsearch.
*   **Configuração**:
    *   Imagem: `docker.elastic.co/kibana/kibana:8.10.2`
    *   **Porta**: `5601` (mapeada para `5601` no host).
    *   **Dependência**: Conecta-se ao `elasticsearch`.

### `discovery`

*   **Descrição**: Servidor Eureka, responsável pelo registro e descoberta de serviços na arquitetura de microserviços.
*   **Configuração**:
    *   Imagem: `gacacio/discovery:0.9.0`
    *   **Porta**: `8761` (mapeada para `8761` no host).

### `gateway`

*   **Descrição**: Gateway de API, ponto de entrada para as requisições externas, responsável por roteamento, autenticação e outras políticas.
*   **Configuração**:
    *   Imagem: `gacacio/gateway:0.14.0`
    *   **Porta**: `8192` (mapeada para a porta `8080` interna do contêiner).
    *   **Variáveis de Ambiente**: `URL_DISCOVERY`, `LOGSTASH`, `CHAVE_API_KEY`.
    *   **Dependências**: `postgres`, `redis`, `elasticsearch`, `kibana`, `logstash`, `discovery`.

### `users`

*   **Descrição**: Microserviço de gestão de usuários.
*   **Configuração**:
    *   Imagem: `gacacio/users:0.23.0`
    *   **Porta**: `8197` (mapeada para a porta `8080` interna do contêiner).
    *   **Variáveis de Ambiente**: `DB_URL`, `USER_DB`, `PASSWORD_DB`, `URL_DISCOVERY`, `REDIS_HOST`, `REDIS_PORT`, `LOGSTASH`.
    *   **Dependências**: `postgres`, `redis`, `elasticsearch`, `logstash`, `discovery`.

### `lista`

*   **Descrição**: Microserviço de gestão de listas de compra.
*   **Configuração**:
    *   Imagem: `gacacio/lista:0.21.0`
    *   **Porta**: `8193` (mapeada para a porta `8080` interna do contêiner).
    *   **Variáveis de Ambiente**: `DB_URL`, `USER_DB`, `PASSWORD_DB`, `URL_DISCOVERY`, `REDIS_HOST`, `REDIS_PORT`, `LOGSTASH`.
    *   **Dependências**: `postgres`, `redis`, `elasticsearch`, `logstash`, `discovery`.

### `notification`

*   **Descrição**: Microserviço de envio de notificações (e-mail, etc.).
*   **Configuração**:
    *   Imagem: `notification:1`
    *   **Porta**: `8194` (mapeada para a porta `8080` interna do contêiner).
    *   **Variáveis de Ambiente**: `DB_URL`, `USER_DB`, `PASSWORD_DB`, `URL_DISCOVERY`, `LOGSTASH`, `MAIL_HOST`, `MAIL_PORT`, `MAIL_USERNAME`, `MAIL_PASSWORD`, `CHAVES_DE_ACESSO`.
    *   **Dependências**: `postgres`, `elasticsearch`, `logstash`, `discovery`.

## Configuração do Banco de Dados (PostgreSQL)

O serviço `postgres` é inicializado com um `Dockerfile` que copia o script `init.sql` para o diretório `/docker-entrypoint-initdb.d`. Este script é executado automaticamente na primeira vez que o contêiner PostgreSQL é iniciado, configurando o banco de dados com:

*   Criação de esquemas específicos para cada microserviço (`gl_user`, `gl_lista`, `gl_notification`).
*   Criação de usuários de banco de dados com permissões específicas para cada esquema.
*   Configurações de performance e segurança (`ALTER SYSTEM` para `max_connections`, `work_mem`, `password_encryption`, `log_connections`, `pgaudit`, etc.).

## Logging Centralizado (ELK Stack)

O projeto utiliza a stack ELK (Elasticsearch, Logstash, Kibana) para coleta, processamento, armazenamento e visualização de logs:

*   **Logstash**: Configurado para receber logs JSON via TCP na porta `5000` (conforme `logstash.conf`). Os microserviços devem ser configurados para enviar seus logs para `logstash:5000`.
*   **Elasticsearch**: Armazena os logs processados pelo Logstash.
*   **Kibana**: Permite a visualização e análise dos logs armazenados no Elasticsearch através de uma interface web.

## Como Iniciar o Projeto

Para levantar todos os serviços, certifique-se de ter o Docker e o Docker Compose instalados.

1.  **Navegue até o diretório `devops`**:
    ```bash
    cd /home/teiti-10337/Documentos/projetos/projeto-lista-de-compra/devops
    ```
2.  **Inicie os serviços**:
    ```bash
    docker-compose up -d
    ```
    Este comando construirá as imagens necessárias (para `postgres`) e iniciará todos os contêineres em segundo plano.

3.  **Verifique o status dos serviços**:
    ```bash
    docker-compose ps
    ```

## Acessando os Serviços

Após iniciar os serviços, você pode acessá-los nas seguintes portas (assumindo `localhost`):

*   **PostgreSQL**: `localhost:5432`
*   **Redis**: `localhost:6379`
*   **Elasticsearch**: `localhost:9200`
*   **Kibana**: `localhost:5601`
*   **Eureka Discovery**: `localhost:8761`
*   **Gateway API**: `localhost:8192`
*   **Users Service**: `localhost:8197`
*   **Lista Service**: `localhost:8193`
*   **Notification Service**: `localhost:8194`

## Parar e Remover os Serviços

Para parar os serviços sem remover os volumes de dados:

```bash
docker-compose stop
```

Para parar e remover os contêineres, redes e volumes (cuidado, isso removerá os dados persistidos):

```bash
docker-compose down -v
```