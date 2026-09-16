---
type: arch
title: Архитектура Shop — обзор
status: approved
owner: architect
audience: architect, developer
version: 1.2.0
last_reviewed: 2026-09-16
tags: [architecture]
related:
  - ../tech/architecture-overview.md
  - ../adr/
---

# Архитектура Shop — обзор

## Контекст

Shop — платформа e-commerce, которая должна:

- держать 10k RPS на каталог в пиках;
- соответствовать 152-ФЗ (хранение в РФ, фискализация) и GDPR;
- поддерживать несколько storefront-ов на одной установке (multi-tenant).

## Контейнеры

![containers](diagrams/containers.png)

| Контейнер | Технология | Ответственность |
|---|---|---|
| Storefront | Nuxt 3 | Витрина (SSR + PWA) |
| Admin | Vue 3 | Бэк-офис |
| API | .NET 8 | Backend |
| Jobs | .NET 8 + Redis | Фоновые задачи |
| Postgres | PostgreSQL 16 | Основное хранилище |
| Redis | Redis 7 | Кэш, очереди, rate-limit |
| Object storage | S3-совместимое | Медиа |
| CDN | CloudFront / аналог | Раздача статики |

## Компоненты

![components](diagrams/components.png)

Подробный разбор модулей — в [tech/architecture-overview.md](../tech/architecture-overview.md).

## Ключевые потоки

### Оформление заказа

![checkout-flow](diagrams/checkout-flow.png)

1. Клиент добавляет товар в корзину (Storefront → API: `POST /api/v1/carts/{id}/items`).
2. Клиент начинает checkout (`POST /api/v1/checkouts`).
3. Клиент оплачивает (Checkout → Payments → провайдер).
4. После успешной оплаты — `Order.Paid` event.
5. Jobs: фискализация, резервирование, уведомление.

## Нефункциональные требования

- **Доступность:** 99.9% (8.7 ч простоя в год).
- **RPS каталога:** 10k sustained, 25k peak.
- **Latency API:** p95 < 200ms для catalog/read, p95 < 500ms для checkout.
- **RPO/RTO:** RPO 5 мин, RTO 1 час.

## Связанные ADR

- [ADR-0001. PostgreSQL](../adr/0001-use-postgres.md)
- [ADR-0002. Event-driven jobs через Redis](../adr/0002-event-driven-jobs.md)
