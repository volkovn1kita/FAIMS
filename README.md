# FAIMS — First Aid Kit Information Management System

[![ASP.NET Core](https://img.shields.io/badge/ASP.NET%20Core-9.0-512BD4?logo=dotnet&logoColor=white)](https://dotnet.microsoft.com/)
[![Flutter](https://img.shields.io/badge/Flutter-Dart-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![React](https://img.shields.io/badge/React-TypeScript-61DAFB?logo=react&logoColor=black)](https://react.dev/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

> Iнформацiйна система управлiння аптечками першої допомоги з мобiльним застосунком, веб-панеллю адмiнiстратора та серверним API.

---

## Змiст

- [Опис проєкту](#опис-проєкту)
- [Основнi можливостi](#основнi-можливостi)
- [Архiтектура](#архiтектура)
- [Технологiчний стек](#технологiчний-стек)
- [Структура проєкту](#структура-проєкту)
- [Знiмки екрану](#знiмки-екрану)
- [Системнi вимоги](#системнi-вимоги)
- [Встановлення та запуск](#встановлення-та-запуск)
  - [Запуск через Docker](#запуск-через-docker)
  - [Запуск мобiльного застосунку](#запуск-мобiльного-застосунку)
- [Змiннi оточення](#змiннi-оточення)
- [API документацiя](#api-документацiя)
- [Docker-сервiси](#docker-сервiси)
- [Тестування](#тестування)
- [Автор](#автор)

---

## Опис проєкту

**FAIMS** (First Aid Kit Information Management System) — це комплексна iнформацiйна система для управлiння аптечками першої допомоги в органiзацiях. Система складається з трьох основних компонентiв:

1. **Серверна частина (Backend API)** — RESTful API на базi ASP.NET Core 9.0 з PostgreSQL
2. **Мобiльний застосунок** — кросплатформний додаток на Flutter (Android / iOS)
3. **Веб-панель адмiнiстратора** — адмiнiстративна панель на React + TypeScript + Ant Design

Система забезпечує повний цикл управлiння медикаментами: вiд додавання та облiку до списання та поповнення, з автоматичним монiторингом термiнiв придатностi та push-сповiщеннями.

---

## Основнi можливостi

### Мобiльний застосунок (Flutter)

| Можливiсть | Опис |
|---|---|
| Рольовий доступ | Роздiлення прав для Адмiнiстратора та Користувача |
| Панель керування | Статистика та загальний огляд для адмiнiстратора |
| Управлiння вiддiлами та кiмнатами | Створення, редагування, видалення |
| Управлiння аптечками | Повний CRUD з вiдстеженням медикаментiв |
| Життєвий цикл медикаментiв | Додавання, використання, списання, поповнення |
| Монiторинг термiнiв придатностi | Push-сповiщення через Firebase Cloud Messaging |
| Аналiтика | Iнтерактивнi графiки (fl_chart) |
| Генерацiя звiтiв | Формування PDF-звiтiв |
| Профiль користувача | Завантаження аватару, редагування даних |
| Багатомовнiсть | Українська та англiйська мови |
| Безпечне зберiгання | Захищене зберiгання токенiв авторизацiї |

### Веб-панель адмiнiстратора (React + Ant Design)

| Можливiсть | Опис |
|---|---|
| Управлiння користувачами | Повний CRUD для облiкових записiв |
| Управлiння структурою | Вiддiли та кiмнати органiзацiї |
| Контроль аптечок | Перегляд та управлiння усiма аптечками |
| Звiтнiсть | Критичнi позицiї, закупiвлi, утилiзацiя |
| Аналiтика | Вiзуалiзацiя даних за допомогою графiкiв |

### Серверне API (ASP.NET Core)

| Можливiсть | Опис |
|---|---|
| RESTful API | 6 контролерiв: User, Department, FirstAidKit, Dashboard, Analytics, Reporting |
| Автентифiкацiя | JWT Bearer токени з механiзмом refresh-токенiв |
| Авторизацiя | Рольова модель доступу |
| Обмеження запитiв | 5 зап./хв. (автентифiкацiя), 150 зап./хв. (API) |
| CORS | Налаштована пiдтримка крос-доменних запитiв |
| Логування | Serilog (консоль + ротацiя файлiв) |
| Мiграцiї | Entity Framework Core |
| Push-сповiщення | Firebase Cloud Messaging для алертiв термiнiв придатностi |

---

## Архiтектура

Проєкт побудований за принципами **Clean Architecture** з чiтким розподiлом вiдповiдальностi:

```
┌─────────────────────────────────────────────────────────┐
│                    Клiєнтський рiвень                   │
│  ┌─────────────────┐       ┌──────────────────────┐     │
│  │  Flutter App     │       │  React Admin Panel   │     │
│  │  (Android/iOS)   │       │  (Web)               │     │
│  │  Provider Pattern│       │  Axios Interceptors  │     │
│  └────────┬─────────┘       └──────────┬───────────┘     │
└───────────┼─────────────────────────────┼────────────────┘
            │          HTTP/REST          │
            ▼                             ▼
┌─────────────────────────────────────────────────────────┐
│                  Backend (ASP.NET Core 9.0)              │
│  ┌─────────────────────────────────────────────────┐     │
│  │  Presentation Layer — Controllers, Middleware    │     │
│  │  JWT Auth, Rate Limiting, CORS, Swagger          │     │
│  └──────────────────────┬──────────────────────────┘     │
│  ┌──────────────────────▼──────────────────────────┐     │
│  │  Application Layer — Services, DTOs, Configs     │     │
│  └──────────────────────┬──────────────────────────┘     │
│  ┌──────────────────────▼──────────────────────────┐     │
│  │  Domain Layer — Entities, Enums                  │     │
│  └──────────────────────┬──────────────────────────┘     │
│  ┌──────────────────────▼──────────────────────────┐     │
│  │  Infrastructure Layer — EF Core, Repositories,   │     │
│  │  Firebase, External Services                     │     │
│  └──────────────────────┬──────────────────────────┘     │
└─────────────────────────┼────────────────────────────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │  PostgreSQL 15        │
              │  (Alpine)             │
              └───────────────────────┘
```

### Архiтектурнi патерни

- **Clean Architecture** — Domain → Application → Infrastructure → Backend
- **Repository Pattern** — абстракцiя доступу до даних через репозиторiї
- **Provider Pattern** — управлiння станом у Flutter-застосунку
- **Axios Interceptors** — перехоплення HTTP-запитiв у React-панелi для автоматичного оновлення токенiв

---

## Технологiчний стек

### Серверна частина

| Технологiя | Версiя | Призначення |
|---|---|---|
| ASP.NET Core | 9.0 | Web API фреймворк |
| Entity Framework Core | — | ORM для роботи з базою даних |
| PostgreSQL | 15 | Реляцiйна база даних |
| Serilog | — | Структуроване логування |
| JWT Bearer | — | Автентифiкацiя та авторизацiя |
| Firebase Admin SDK | — | Push-сповiщення |
| Swagger / OpenAPI | — | Документацiя API |

### Мобiльний застосунок

| Технологiя | Призначення |
|---|---|
| Flutter (Dart) | Кросплатформна розробка (Android / iOS) |
| Provider | Управлiння станом |
| fl_chart | Побудова графiкiв та дiаграм |
| Firebase Cloud Messaging | Push-сповiщення |
| Secure Storage | Безпечне зберiгання токенiв |

### Адмiн-панель

| Технологiя | Призначення |
|---|---|
| React | UI-бiблiотека |
| TypeScript | Статична типiзацiя |
| Ant Design | Бiблiотека UI-компонентiв |
| Axios | HTTP-клiєнт з iнтерсепторами |

### Iнфраструктура

| Технологiя | Призначення |
|---|---|
| Docker | Контейнеризацiя сервiсiв |
| Docker Compose | Оркестрацiя контейнерiв |
| nginx | Веб-сервер для адмiн-панелi |

---

## Структура проєкту

```
FAIMS/
├── Backend/                 # ASP.NET Core Web API (Presentation Layer)
│   ├── Controllers/         # API-контролери
│   ├── Middleware/           # Middleware компоненти
│   └── Program.cs           # Точка входу застосунку
│
├── Application/             # Бiзнес-логiка (Application Layer)
│   ├── Services/            # Сервiси бiзнес-логiки
│   ├── DTOs/                # Data Transfer Objects
│   └── Configs/             # Конфiгурацiї
│
├── Domain/                  # Доменний рiвень (Domain Layer)
│   ├── Entities/            # Доменнi сутностi
│   └── Enums/               # Перелiчення
│
├── Infrastructure/          # Iнфраструктурний рiвень
│   ├── Data/                # DbContext, мiграцiї
│   ├── Repositories/        # Реалiзацiя репозиторiїв
│   └── Services/            # Зовнiшнi сервiси (Firebase тощо)
│
├── Tests/                   # Модульнi тести
│
├── frontend/                # Flutter мобiльний застосунок
│   ├── lib/                 # Вихiдний код Dart
│   ├── android/             # Android-специфiчнi файли
│   └── ios/                 # iOS-специфiчнi файли
│
├── admin-panel/             # React адмiн-панель
│   ├── src/                 # Вихiдний код TypeScript/React
│   └── public/              # Статичнi файли
│
├── scripts/                 # Допомiжнi скрипти
│   ├── run_flutter.sh       # Автовизначення IP (Linux/macOS)
│   └── run_flutter.bat      # Автовизначення IP (Windows)
│
├── docker-compose.yml       # Оркестрацiя Docker-контейнерiв
├── .env.example             # Шаблон змiнних оточення
└── README.md                # Документацiя проєкту
```

---

## Знiмки екрану

<!--
Додайте знiмки екрану вашого застосунку нижче.
Рекомендованi знiмки:
  - Екран авторизацiї
  - Головна панель (Dashboard)
  - Список аптечок
  - Деталi аптечки з медикаментами
  - Аналiтика (графiки)
  - Адмiн-панель (веб)
-->

<p align="center">
  <i>Знiмки екрану будуть додано пiзнiше</i>
</p>

<!--
Приклад додавання знiмкiв:

<p align="center">
  <img src="docs/screenshots/login.png" width="250" alt="Екран авторизацiї"/>
  <img src="docs/screenshots/dashboard.png" width="250" alt="Головна панель"/>
  <img src="docs/screenshots/kits.png" width="250" alt="Список аптечок"/>
</p>

<p align="center">
  <img src="docs/screenshots/admin-panel.png" width="700" alt="Адмiн-панель"/>
</p>
-->

---

## Системнi вимоги

### Для запуску через Docker (рекомендовано)

| Компонент | Мiнiмальна вимога |
|---|---|
| Docker | 20.10+ |
| Docker Compose | 2.0+ |
| ОЗП | 4 ГБ |
| Дисковий простiр | 5 ГБ |

### Для локальної розробки

| Компонент | Вимога |
|---|---|
| .NET SDK | 9.0+ |
| Node.js | 18+ |
| Flutter SDK | 3.x+ |
| PostgreSQL | 15+ |
| Git | 2.x+ |

### Мобiльний застосунок

| Платформа | Мiнiмальна версiя |
|---|---|
| Android | 6.0 (API 23) |
| iOS | 12.0 |

---

## Встановлення та запуск

### Запуск через Docker

Це рекомендований спосiб запуску серверної частини та адмiн-панелi.

**1. Клонування репозиторiю**

```bash
git clone <url-репозиторiю>
cd FAIMS
```

**2. Налаштування змiнних оточення**

```bash
cp .env.example .env
```

Вiдкрийте файл `.env` та встановiть необхiднi значення:

```env
JWT_SECRET_KEY=ваш_секретний_ключ_мiнiмум_32_символи
```

> **Увага:** JWT_SECRET_KEY повинен мiстити щонайменше 32 символи.

**3. Запуск контейнерiв**

```bash
docker-compose up --build
```

**4. Перевiрка працездатностi**

Пiсля успiшного запуску будуть доступнi:

| Сервiс | URL |
|---|---|
| Backend API | http://localhost:5076 |
| Swagger документацiя | http://localhost:5076/swagger |
| Адмiн-панель | http://localhost:3000 |

---

### Запуск мобiльного застосунку

**1. Встановлення залежностей**

```bash
cd frontend
flutter pub get
```

**2. Запуск з автовизначенням IP-адреси хоста**

Linux / macOS:
```bash
./scripts/run_flutter.sh
```

Windows:
```cmd
scripts\run_flutter.bat
```

**3. Або ручний запуск iз зазначенням IP**

```bash
flutter run --dart-define=API_HOST=192.168.1.100
```

> **Примiтка:** Замiнiть `192.168.1.100` на IP-адресу машини, де запущено Backend API. Мобiльний пристрiй або емулятор повинен мати мережевий доступ до цiєї адреси.

---

## Змiннi оточення

Шаблон змiнних оточення знаходиться у файлi `.env.example`.

| Змiнна | Опис | Обов'язкова |
|---|---|---|
| `JWT_SECRET_KEY` | Секретний ключ для пiдпису JWT-токенiв (мiнiмум 32 символи) | Так |

---

## API документацiя

Iнтерактивна документацiя API доступна через Swagger UI за адресою:

```
http://localhost:5076/swagger
```

### Основнi групи ендпоiнтiв

| Група | Ендпоiнти | Опис |
|---|---|---|
| **Auth** | `POST /login`, `POST /refresh-token`, `POST /register-organization` | Автентифiкацiя та реєстрацiя |
| **Users** | CRUD, профiль, завантаження аватару | Управлiння користувачами |
| **Departments** | CRUD з кiмнатами | Управлiння вiддiлами |
| **FirstAidKits** | CRUD, використання, списання, поповнення медикаментiв | Управлiння аптечками |
| **Dashboard** | Загальна статистика | Панель огляду |
| **Analytics** | Глобальна статистика медикаментiв | Аналiтичнi данi |
| **Reports** | Критичнi позицiї, стан аптечок, закупiвлi, утилiзацiя | Формування звiтiв |

### Обмеження запитiв (Rate Limiting)

| Полiтика | Лiмiт | Область застосування |
|---|---|---|
| Автентифiкацiя | 5 запитiв / хвилину | Ендпоiнти входу та реєстрацiї |
| Загальне API | 150 запитiв / хвилину | Усi iншi ендпоiнти |

---

## Docker-сервiси

Система розгортається у виглядi трьох Docker-контейнерiв:

| Сервiс | Образ | Порт | Опис |
|---|---|---|---|
| `postgres_db` | PostgreSQL 15 Alpine | 5433 | Реляцiйна база даних |
| `backend` | ASP.NET Core 9.0 | 5076 | Серверне API |
| `admin-panel` | React + nginx | 3000 | Веб-панель адмiнiстратора |

### Дiаграма Docker-сервiсiв

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  admin-panel │     │   backend    │     │  postgres_db │
│  (nginx)     │────▶│  (ASP.NET)   │────▶│ (PostgreSQL) │
│  :3000       │     │  :5076       │     │  :5433       │
└──────────────┘     └──────────────┘     └──────────────┘
```

---

## Тестування

Для запуску модульних тестiв:

```bash
cd Tests
dotnet test
```

---

## Автор

Дипломний проєкт розроблено в рамках квалiфiкацiйної роботи.

---

<p align="center">
  <b>FAIMS</b> — First Aid Kit Information Management System
</p>
