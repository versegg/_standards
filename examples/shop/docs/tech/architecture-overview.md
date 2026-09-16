---
type: tech
title: Архитектурный обзор Shop
status: approved
owner: backend-team
audience: developer, architect
version: 1.2.0
last_reviewed: 2026-09-16
tags: [architecture]
related:
  - ../arch/overview.md
  - ../adr/0001-use-postgres.md
  - ../adr/0002-event-driven-jobs.md
  - ./data-model.md
---

# Архитектурный обзор Shop

## Верхнеуровневая схема

Shop состоит из следующих модулей (BC, bounded context):

| Модуль | Ответственность |
|---|---|
| Shop.Core | Базовые абстракции, persistence, events |
| Shop.Catalog | Товары, таксономия |
| Shop.Inventory | Склад, остатки, резервы |
| Shop.Orders | Заказы, жизненный цикл |
| Shop.Checkout | Корзина, оформление, промо |
| Shop.Payments | Платёжные провайдеры, фискализация |
| Shop.Profiles | Клиенты, адреса, избранное |
| Shop.Storefront | SEO, каталог для витрины |
| Shop.Content | Страницы, справка |
| Shop.Media | Загрузка, обработка, 360-spin |
| Shop.Compliance | 152-ФЗ, GDPR, cookie, DSAR |
| Shop.Jobs.Redis | Фоновые задачи |

## Слои

- **Api** — REST + GraphQL endpoint.
- **Core** — доменная логика без зависимостей.
- **Infrastructure** — реализация persistence, caching, external API.
- **Persistence** — EF Core, конфигурации, миграции.

## Ключевые потоки

- **Оформление заказа:** Cart → Checkout → Order → Payment → Order.Paid → Inventory.Reserve.
- **Фискализация:** Order.Paid → Payments → Fiscal → Ofd.
- **Compliance:** User.Action → Compliance.AuditLog.

## Связанное

- [Architecture overview](../arch/overview.md) (человекочитаемая версия)
- [ADR-0001: PostgreSQL](../adr/0001-use-postgres.md)
- [ADR-0002: Event-driven jobs](../adr/0002-event-driven-jobs.md)
