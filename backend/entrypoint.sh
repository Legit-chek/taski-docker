#!/usr/bin/env bash
set -e

# Ждём, пока поднимется БД (если используется Postgres)
if [ -n "$DB_HOST" ]; then
  echo "Waiting for Postgres at $DB_HOST:$DB_PORT..."
  python - <<'PY'
import os, socket, time

host = os.getenv('DB_HOST')
port = int(os.getenv('DB_PORT', '5432'))
deadline = time.time() + 60

while True:
    try:
        with socket.create_connection((host, port), timeout=3):
            break
    except OSError:
        if time.time() > deadline:
            raise SystemExit('Postgres is not available')
        time.sleep(1)
PY
fi

python manage.py migrate --noinput
python manage.py collectstatic --noinput

exec "$@"
