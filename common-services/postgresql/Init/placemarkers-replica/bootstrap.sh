#!/bin/sh
set -e

: "${PGDATA:=/var/lib/postgresql/data/pgdata}"
: "${PRIMARY_HOST:=cs-pg-placemarkers-primary}"
: "${PRIMARY_PORT:=5432}"
: "${REPLICATION_USER:=replicator}"
: "${REPLICATION_PASSWORD:=replica_password}"

mkdir -p "$PGDATA"
chmod 700 "$PGDATA"

if [ ! -s "$PGDATA/PG_VERSION" ]; then
  echo ">>> Performing base backup from ${PRIMARY_HOST}:${PRIMARY_PORT}..."
  rm -rf "$PGDATA"/*
  export PGPASSWORD="$REPLICATION_PASSWORD"
  pg_basebackup \
    -h "$PRIMARY_HOST" \
    -p "$PRIMARY_PORT" \
    -U "$REPLICATION_USER" \
    -D "$PGDATA" \
    -Fp \
    -Xs \
    -P \
    -R \
    -w
  echo ">>> Base backup completed"
fi

exec /usr/local/bin/docker-entrypoint.sh postgres