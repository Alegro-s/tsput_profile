# Реальное внедрение 1C + Moodle + Портфолио

## 1) Что уже подготовлено в коде
- Приложение переведено на API-first подход: `ApiService` в `lib/data/services/api_service.dart`.
- Убрана зависимость от отсутствующих `assets/data/*.json` для ключевых сущностей.
- Добавлен экран `Portfolio` и провайдер `PortfolioProvider`.
- Авторизация теперь идет через `ApiService.login(...)` с fallback-режимом для разработки.

## 2) Интеграция с 1C
Обычно для 1C используются два пути:
- **OData** (стандартно публикуется в 1C:Enterprise, URL вида `/odata/standard.odata/`).
- **Кастомный HTTP/REST сервис** внутри конфигурации.

### Минимальный план
1. На стороне 1C опубликовать endpoint'ы:
   - `POST /api/auth/login`
   - `GET /api/student`
   - `GET /api/schedule`
   - `GET /api/grades`
   - `GET /api/exams`
   - `GET /api/portfolio`
2. Привести JSON-ответы к моделям Flutter:
   - `Student`, `Schedule`, `Grade`, `Exam`, `PortfolioItem`.
3. Включить JWT/Bearer или токен-сессию и передавать в `Authorization`.
4. Выдать отдельного сервисного пользователя 1C с минимальными правами.

## 3) Интеграция с Moodle
Для Moodle стандартно используется Web Services REST:
- endpoint: `/webservice/rest/server.php`
- параметры: `wstoken`, `wsfunction`, `moodlewsrestformat=json`

### Что нужно сделать
1. Включить Web Services и REST protocol в админке Moodle.
2. Создать Service и добавить функции (например, для курсов/assignments/feedback).
3. Сгенерировать токен для приложения.
4. Добавить в Flutter отдельный Moodle-клиент (можно как часть `ApiService`) для:
   - статуса сдачи лабораторных,
   - комментариев преподавателя,
   - уведомлений о принятии.

## 4) Внутренние уведомления
Рекомендуемая схема:
1. Делать периодический sync (например, каждые 15-30 минут).
2. Сравнивать snapshot текущих данных с предыдущим в локальном хранилище.
3. При изменениях создавать локальные уведомления:
   - новая оценка,
   - комментарий в Moodle,
   - изменение статуса заявки/приказа/стипендии.

## 5) Безопасность
- Никогда не хранить логин/пароль в открытом виде (использовать только secure storage и короткие токены).
- Все API только по HTTPS.
- Добавить pinning сертификата для production.
- Логи с персональными данными отключить.

## 6) Что заменить перед production
- В сборке Flutter задать `--dart-define=INTEGRATION_BASE_URL=https://api.ваш-вуз.ru` (или URL своего Docker/nginx).
- Docker и деплой: `docker-compose.yml`, `deploy/README.md`.
- Удалить fallback-моки из `ApiService` после готовности серверов.
- Добавить e2e-тесты на сценарии входа, загрузки расписания, оценок и портфолио.

## 7) Полная модель данных продукта
- `Student`: id, fullName, group, faculty, specialty, course, admissionDate, graduationDate, email, phone, address, additionalInfo.
- `Schedule`: id, subject, teacher, classroom, startTime, endTime, type.
- `Grade`: id, subject, teacher, value, type, date.
- `Exam`: id, subject, teacher, date, time, classroom, isCompleted, type, grade.
- `PortfolioItem`: id, title, category, status, date, source.
- `Lab (Moodle)`: id, course, title, status, teacherComment, updatedAt.
- `Notification`: id, type, title, text, source, createdAt, isRead.

## 8) Таблица соответствий источников
- 1C: студент, учебный план, оценки, экзамены, расписание, портфолио, приказы, выплаты, заявки.
- Moodle: лабораторные, комментарии преподавателей, статусы сдачи.
- Портал вуза: публичные достижения/портфолио (если нет API, то через backend парсер).
