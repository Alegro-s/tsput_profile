# Деплой Docker и MAX Mini App

## Что поднимается

- **api** — FastAPI на порту `8080`
- **db** — PostgreSQL 16 (данные API пока в коде; БД зарезервирована под уведомления и кэш)
- **nginx** (профиль `web`) — отдаёт Flutter Web и проксирует `/api` на backend

## Быстрый старт на сервере

1. Установи Docker и Docker Compose.
2. Склонируй репозиторий на сервер (или скопируй файлы).
3. В корне проекта:

```bash
docker compose up -d --build
```

Проверка: `curl http://localhost:8080/health`

Логин API (демо): `student@university.ru` / `password123`

## Залить проект на сервер (ты делаешь у себя)

Пример с `scp` (замени `USER` и `HOST`):

```bash
# из каталога с проектом
scp -r . USER@HOST:~/tsput_profile
ssh USER@HOST "cd ~/tsput_profile && docker compose up -d --build"
```

Или через git: `git clone` на сервере и `docker compose up -d --build`.

## Flutter: онлайн к твоему API

Собери приложение с базовым URL сервера:

```bash
flutter run --dart-define=INTEGRATION_BASE_URL=http://YOUR_SERVER_IP:8080
```

Или для релиза:

```bash
flutter build apk --release --dart-define=INTEGRATION_BASE_URL=https://your-domain.ru
```

## Офлайн-режим (тест без сервера)

В приложении включена демо-авторизация без сети: те же `student@university.ru` / `password123`.  
При недоступности сервера выдаётся токен `offline_...`, данные берутся из встроенного мока.

## MAX Mini App

В MAX мини-приложения открываются как **HTTPS URL** в WebView (документация: [dev.max.ru](https://dev.max.ru/docs/webapps/bridge)).

1. Собери Flutter Web с **одним** origin для API и статики (через nginx ниже):

```bash
flutter build web --release --base-href / --dart-define=INTEGRATION_BASE_URL=
```

Для продакшена укажи публичный HTTPS-адрес **без порта** (nginx на 443):

```bash
flutter build web --release --base-href / --dart-define=INTEGRATION_BASE_URL=https://your-domain.ru
```

2. Скопируй `build/web/*` на сервер в каталог `build/web` в корне репозитория (как ожидает `docker-compose`).  
   Если каталога ещё нет: `mkdir -p build/web && cp deploy/web_stub/index.html build/web/index.html`

3. Запусти с профилем `web`:

```bash
docker compose --profile web up -d --build
```

4. В кабинете MAX укажи URL приложения: `https://your-domain.ru/` (обязательно HTTPS).

Скрипты для Windows/Linux: `scripts/build_web_for_max.ps1`, `scripts/build_web_for_max.sh`.

## TLS (HTTPS)

Для MAX нужен валидный сертификат. Варианты: Caddy, Traefik, certbot + nginx — настрой на своём сервере отдельно; в этом репозитории только HTTP-конфиг nginx для примера.
