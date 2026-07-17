## Инфраструктура и Общие сервисы

- **PHP**: 8.5
- **Фреймворк**: Symfony 8.0 + RoadRunner
- **Управление окружением**: `Makefile` (оркестрация сборки, запуска и инициализации всех микросервисов и инфраструктуры)
- **Traefik**: `v3.6` (Reverse proxy)
- **PostgreSQL / PostGIS**: `17-3.5-alpine` / `17-alpine` (включает pgAdmin4 `latest`, primary / replica)
- **Redis**: `7-alpine` (включает RedisInsight `latest`)
- **RabbitMQ**: `3-management`
- **MongoDB**: `6` (включает Mongo Express `latest`)
- **Buggregator**: `latest`

## Что делает (кратко)

1. Пользователь может делать метки на Yandex карте. Добавлять им названия, тип, теги, описания. Сохранять в базу данных.
2. Пользователь может выполнять поиск на **Yandex карте по радиусу**. Задать окружность с произвольным радиусом. Применить фильтры поиска. Может **сохранять результаты поиска меток** и отображать их на карте.
3. Создавать свой собственный набор тегов для каждого типа метки.

Также есть функуционал регистрации, смены пароля, подтверждения email, авторизации (JWT). 

---

> **🎬 Демо-видео:** небольшое видео, которое демонстрирует функционал приложения — [смотреть на Яндекс.Диске](https://disk.yandex.ru/i/xU0GQ61pC3njjQ)

---

## Структура:

Приложение состоит из следующих сервисов:

### Микросервисы (main-services)

- [app-frontend](https://github.com/Vlad812/placemarkers-demo-app-frontend.git) — BFF (Backend For Frontend), отдает пользовательский интерфейс (UI) и проксирует запросы к внутренним микросервисам, хранит сессию в Redis.
- [api-placemarkers-database](https://github.com/Vlad812/placemarkers-demo-api-database.git) — сервис записи (CQRS Write Model), отвечающий за создание, обновление и удаление меток (работает с Primary БД PostgreSQL).
- [api-placemarkers-search](https://github.com/Vlad812/placemarkers-demo-api-search.git) — сервис чтения (CQRS Read Model) для быстрого геопространственного поиска меток по радиусу (работает с Replica БД PostgreSQL).
- [auth-service](https://github.com/Vlad812/placemarkers-demo-auth-service.git) — сервис аутентификации и авторизации, отвечает за выпуск и проверку JWT-токенов, регистрацию пользователей
- [notification-provider](https://github.com/Vlad812/placemarkers-demo-notification-provider.git) — сервис уведомлений, асинхронно обрабатывающий отправку писем (через RabbitMQ).
- [api-placemarkers-collection](https://github.com/Vlad812/placemarkers-demo-api-collection.git) — сервис для работы с пользовательскими коллекциями гео-меток (использует MongoDB).

> у сервисов в README есть описание и API documentation.

### Общие сервисы (common-services)

- **traefik** — reverse proxy / API Gateway, единая точка входа для внешнего HTTP-трафика к микросервисам.
- **postgresql** — PostgreSQL / PostGIS: Primary и Replica для гео-меток, отдельная БД для `auth-service`; включает pgAdmin.
- **redis** — хранилище сессий BFF (`app-frontend`); включает RedisInsight.
- **rabbit** — брокер сообщений RabbitMQ для асинхронных событий (уведомления и т.п.); включает management UI.
- **mongodb** — документоориентированное хранилище для коллекций меток (`api-placemarkers-collection`); включает Mongo Express.
- **buggregator** — локальный debug/SMTP-сервер для просмотра логов, дампов и писем в dev-окружении.



## Что демонстрирует проект:

Проект служит примером построения масштабируемого приложения и демонстрирует применение современных архитектурных паттернов на двух уровнях.

### 1. Паттерны микросервисной архитектуры

- **RESTful API**: Взаимодействие между сервисами и клиентами строится на принципах REST с использованием стандартных HTTP-методов и JSON-формата.
- **Stateless Authentication (JWT)**: Авторизация между микросервисами построена на базе JWT (JSON Web Tokens), что позволяет сервисам проверять права доступа без необходимости хранить состояние сессии (stateless).
- **Асинхронное взаимодействие (Event-Driven)**: Использование брокеров сообщений (RabbitMQ) для асинхронной связи между сервисами (например, для отправки уведомлений или фоновой обработки данных), что повышает отказоустойчивость и уменьшает связность (coupling).
- **Polyglot Persistence (Полиглотное хранение данных)**: Использование наиболее подходящего типа базы данных для конкретной задачи. Например, PostgreSQL + PostGIS используется для строгих реляционных и геопространственных данных, а MongoDB — для гибкого документоориентированного хранения (в сервисе `api-placemarkers-collection`).
- **BFF (Backend For Frontend)**: Использование выделенного сервиса (`app-frontend`) для обслуживания клиентского приложения. Он отдает UI и проксирует запросы к внутренним API, скрывая сложность микросервисной архитектуры от браузера.
- **CQRS на уровне системы (Command Query Responsibility Segregation)**: Физическое разделение сервисов для операций записи и чтения. Сервис `api-placemarkers-database` обрабатывает мутации данных (сохраняет в Primary БД), а `api-placemarkers-search` отвечает за быстрый гео-поиск (читает из Replica БД).
- **API Gateway / Reverse Proxy**: Использование Traefik как единой точки входа, маршрутизирующей внешний трафик к нужным микросервисам на основе путей.
- **Database per Service (База данных на сервис)**: Изоляция данных между различными доменами (например, отдельные базы/схемы для авторизации и гео-меток), что обеспечивает независимость сервисов друг от друга.



### 2. Паттерны на уровне приложения (внутри сервисов)

- **DDD (Domain-Driven Design)**: Проектирование, ориентированное на предметную область. Выделение ядра бизнес-логики (Domain) в независимый слой, использование богатых сущностей (Rich Entities) и объектов-значений (Value Objects) для инкапсуляции правил и защиты инвариантов.
- **ADR (Action-Domain-Responder)**: Отказ от классических "толстых" MVC-контроллеров в пользу узконаправленных Actions (один класс — один эндпоинт). Action только принимает HTTP-запрос, передает его в слой приложения и возвращает ответ.
- **Clean Architecture (Чистая архитектура)**: Строгое разделение кода на слои (Infrastructure, Application, Domain). Инфраструктура (HTTP, БД) зависит от бизнес-логики, а не наоборот.
- **CQRS на уровне кода**: Разделение моделей доступа к данным. Использование `Repositories` (Doctrine ORM) для записи и изменения состояния сущностей, и `Fetchers` (сырые SQL-запросы через Doctrine DBAL) для максимально быстрого чтения без накладных расходов ORM.
- **Self-validated DTO (Самовалидирующиеся объекты)**: Использование паттерна Command/Query объектов со встроенной строгой валидацией (через `Webmozart\Assert`) при их создании. В слой бизнес-логики (Handlers) попадают только 100% валидные и типизированные данные.

---



### Используемые Symfony Bundles

В микросервисах используется такие bundles как:

- **BaldinofRoadRunnerBundle**: Интеграция Symfony с сервером RoadRunner для обеспечения высокой производительности.
- **LexikJWTAuthenticationBundle**: Реализация Stateless авторизации через JWT-токены.
- **SecurityBundle**: Базовые компоненты безопасности Symfony.
- **DoctrineBundle & DoctrineMigrationsBundle**: Работа с реляционными базами данных (PostgreSQL) и управление миграциями.
- **DoctrineMongoDBBundle**: Работа с документоориентированной базой данных MongoDB (используется в `api-placemarkers-collection`).
- **MonologBundle**: Единый стандарт логирования.
- **TwigBundle**: Шаблонизатор (используется в BFF `app-frontend` и сервисе уведомлений `notification-provider`).
- **FrameworkBundle**: Базовый каркас Symfony во всех сервисах. (Включает в себя компонент **Messenger** для работы с RabbitMQ).

---



## Как устроен:

Этот репозиторий представляет собой **workstation** и является корневым каталогом для приложения.
Содержит главный **Makefile** для управления инфраструктурой.

Структура каталогов: 

<p align="center">
  <img src="doc/src/pl_catalogs.jpg" alt="Структура каталогов" />
</p>

> `common-services` — содержат общие сервисы. Каждый имеет свой docker compose. Хранятся в этом репозитории.

> `main-services` — содержит основные сервисы приложения. Каждый в своём репозитории.

> `Makefile` — оркестрация всего окружения:
>
> - `make app-setup` — первичная настройка: сеть Docker, клон репозиториев, сборка и инициализация сервисов;
> - `make app-up` — запуск common-services и main-services;
> - `make app-down` — остановка всех сервисов;
> - `make app-clear` — полная остановка и удаление Docker-сети.

При этом сервисы сгруппированы. Так выглядит запущенное приложение в UI docker client. 

![Docker Containers](doc/src/pl_docker_containers.jpg)

---

## Полная схема архитектуры

![Полная схема архитектуры](doc/src/pl_schema_services.jpg)

### Связи: сервис → база

![Связи сервис → база](doc/src/pl_db_services.jpg)


### Инициализация PostgreSQL (`common-services/postgresql/Init`)

SQL-скрипты и shell-скрипты для первичной настройки баз данных. Выполняются **один раз** при первом запуске контейнера (когда volume пустой), через стандартный механизм PostgreSQL `/docker-entrypoint-initdb.d/`. Порядок выполнения — по имени файла (префиксы `00_`, `01_`, …).

**`Init/placemarkers/`** — Primary БД `placemarkers_db` (`cs-pg-placemarkers-primary`):
- `00_hba.sh` — настраивает `pg_hba.conf` для репликации;
- `01_replication.sql` — создаёт пользователя `replicator` для WAL-репликации;
- `02_init.sql` — включает PostGIS, создаёт таблицы `placemarker_types`, `tags`, `placemarkers` и индексы;
- `03_test_data.sql` — тестовые теги и метки для демо.

**`Init/placemarkers-replica/`** — Replica БД (`cs-pg-placemarkers-replica`):
- `bootstrap.sh` — при первом запуске делает `pg_basebackup` с Primary и поднимает read-only реплику (streaming replication).

**`Init/auth/`** — БД `placemarkers_user_db` (`cs-pg-auth`):
- `init.sql` — создаёт таблицы `users`, `refresh_tokens` (с полем `family` для token family), тестового пользователя `test@example.com`.

Инициализация запускается через `make app-setup` → `cs-pg-placemarkers-init` и `cs-pg-auth-init`. После выполнения скриптов контейнеры останавливаются; при следующем `make app-up` базы поднимаются уже с готовой схемой и данными.
