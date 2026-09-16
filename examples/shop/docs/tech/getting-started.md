---
type: tech
title: Как поднять Shop локально
status: approved
owner: backend-team
audience: developer
version: 1.2.0
last_reviewed: 2026-09-16
tags: [onboarding, backend]
related:
  - ./architecture-overview.md
  - ./data-model.md
  - ./testing.md
---

# Как поднять Shop локально

## Предусловия

- .NET 8 SDK
- Docker Desktop
- Node.js 20+
- pnpm 9+

## Шаги

1. Склонировать репозиторий.
2. Поднять инфраструктуру:

   ```bash
   docker compose -f deploy/docker-compose.dev.yml up -d
   ```

3. Применить миграции:

   ```bash
   dotnet ef database update --project src/Shop.Persistence
   ```

4. Заполнить данными:

   ```bash
   dotnet run --project src/Shop.Seeder
   ```

5. Запустить API:

   ```bash
   dotnet run --project src/Shop.Api
   ```

6. Запустить фронт:

   ```bash
   pnpm --dir src/frontend dev
   ```

API будет на `http://localhost:5000`, фронт — на `http://localhost:5173`.

## Что дальше

- [Архитектурный обзор](./architecture-overview.md)
- [Модель данных](./data-model.md)
- [Как писать тесты](./testing.md)
