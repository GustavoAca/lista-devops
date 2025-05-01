FROM postgres:14.4-bullseye

RUN apt-get update && apt-get install vim -y

ADD init.sql /docker-entrypoint-initdb.d

ENV TZ='America/Sao_Paulo'

EXPOSE 5432