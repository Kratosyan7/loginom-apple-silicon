#!/bin/bash
# Запуск Loginom Community на Apple Silicon Mac.
# Скрипт сам соберёт образ при первом запуске и поднимет контейнер.
set -e

IMAGE="loginom-box64:local"
NAME="loginom"
SHARE="$HOME/Loginom"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP="$HERE/loginom-community"

red()  { printf "\033[31m%s\033[0m\n" "$1"; }
green(){ printf "\033[32m%s\033[0m\n" "$1"; }

# --- проверки окружения ---
if [ "$(uname -s)" != "Darwin" ]; then
  red "Скрипт рассчитан на macOS."; exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  red "Docker не найден. Установите Docker Desktop: https://www.docker.com/products/docker-desktop/"
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker не запущен, запускаю..."
  open -a Docker || { red "Не удалось запустить Docker Desktop."; exit 1; }
  printf "Жду готовности демона"
  until docker info >/dev/null 2>&1; do printf "."; sleep 2; done
  echo
fi

if [ ! -x "$APP/loginom" ]; then
  red "Не найден $APP/loginom"
  cat <<'HELP'

Файлы Loginom в репозиторий не входят — это запрещено лицензией (п. 5.8).
Скачайте их сами, это бесплатно:

  1. https://loginom.ru/community  — раздел загрузки, версия для Linux
  2. Положите архив loginom-community-*.tar.gz рядом с этим скриптом
  3. Распакуйте:  tar -xf loginom-community-*.tar.gz
  4. Запустите скрипт снова

HELP
  exit 1
fi

# --- сборка образа ---
if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  echo "Собираю образ (первый раз, 5-10 минут)..."
  docker build --platform linux/arm64 -t "$IMAGE" "$HERE"
  green "Образ собран."
fi

# --- запуск ---
mkdir -p "$SHARE" "$HOME/.loginom"
docker rm -f "$NAME" >/dev/null 2>&1 || true
docker run -d --name "$NAME" --platform linux/arm64 \
  -p 127.0.0.1:5900:5900 --shm-size=1g \
  -v "$APP:/opt/loginom" \
  -v "$HOME/.loginom:/root/.loginom" \
  -v "$SHARE:/data" \
  "$IMAGE" >/dev/null

printf "Жду запуска"
for i in $(seq 1 60); do
  if docker exec "$NAME" sh -c 'ps -eo comm | grep -q x11vnc' 2>/dev/null; then break; fi
  printf "."; sleep 2
done
echo

green "Готово."
cat <<INFO

  Подключение : vnc://localhost:5900
  Пароль      : loginom
  Общая папка : $SHARE  (в Loginom — раздел «Данные» слева)

Окно будет белым первые 60-90 секунд, пока грузится интерфейс. Это нормально.
Чтобы запустить снова в следующий раз — этот же ./run.sh

INFO
open vnc://localhost:5900 2>/dev/null || true
