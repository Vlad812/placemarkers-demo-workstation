#!/bin/bash
set -e

echo ">>> Configuring pg_hba.conf for replication..."
# Разрешаем подключение для репликации от репликатора
echo "host replication replicator all scram-sha-256" >> "$PGDATA/pg_hba.conf"
# Разрешаем подключение для всех остальных (если нужно)
echo "host all all all scram-sha-256" >> "$PGDATA/pg_hba.conf"