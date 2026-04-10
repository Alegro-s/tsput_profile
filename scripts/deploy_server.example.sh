#!/usr/bin/env bash
# Пример: залить проект на сервер и поднять Docker (замени USER, HOST, PATH)
set -euo pipefail
USER_HOST="${1:?usage: $0 user@host}"
REMOTE_DIR="${2:-~/tsput_profile}"

rsync -avz --exclude '.git' --exclude 'build' ./ "$USER_HOST:$REMOTE_DIR/"
ssh "$USER_HOST" "cd $REMOTE_DIR && docker compose up -d --build"

echo "Готово. Проверь: curl http://SERVER:8080/health"
