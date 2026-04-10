# Backend for TSPUT Profile

Это backend-слой для Flutter-клиента.  
Он закрывает вопрос демонстрации "реального продукта" даже без URL от вуза.

## Docker (рекомендуется)

Из **корня репозитория** (не из `backend/`):

```bash
docker compose up -d --build
```

API: `http://localhost:8080/health`

Полная инструкция (nginx, MAX, деплой на сервер): см. `deploy/README.md`.

## Что уже есть
- `POST /api/auth/login`
- `GET /api/student`
- `GET /api/schedule`
- `GET /api/grades`
- `GET /api/exams`
- `GET /api/portfolio`
- `GET /api/moodle/labs`
- `GET /health`

Все endpoint'ы совместимы с текущими моделями в `lib/`.

## Быстрый запуск
1. Установи Python 3.11+.
2. В каталоге `backend/`:
   - `python -m venv .venv`
   - Windows: `.venv\Scripts\activate`
   - `pip install -r requirements.txt`
3. Создай `.env` на основе `.env.example`.
4. Запусти:
   - `uvicorn app.main:app --host 0.0.0.0 --port 8080 --reload`

## Режимы работы
- `MOCK_MODE=true` — полностью рабочий демо-контур для продажи.
- `MOCK_MODE=false` — подключение к реальным системам (1C/Moodle), когда дадут URL и ключи.

## Как подружить с Flutter
Один параметр сборки:

```bash
flutter run --dart-define=INTEGRATION_BASE_URL=http://СЕРВЕР:8080
```

Или для Web/MAX (один HTTPS-домен с nginx):

```bash
flutter build web --release --base-href / --dart-define=INTEGRATION_BASE_URL=https://твой-домен.ru
```

Все запросы идут на `INTEGRATION_BASE_URL` + `/api/...`.

## Что добавить следующим шагом
- JWT refresh токены.
- PostgreSQL + таблицы snapshot/notifications.
- Реальные адаптеры 1C OData и Moodle `server.php`.
