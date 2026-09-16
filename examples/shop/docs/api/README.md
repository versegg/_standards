---
type: api
title: Shop API — обзор
status: approved
owner: backend-team
audience: developer, partner
version: 1.2.0
last_reviewed: 2026-09-16
tags: [api]
related:
  - ./openapi.yaml
  - ./checkout-create-order.md
  - ../arch/overview.md
---

# Shop API — обзор

## Базовый URL

```
https://api.shop.example.com/api/v1
```

## Авторизация

OAuth 2.0 с bearer-токенами. Получение — через `POST /api/v1/auth/token`.

| Scope | Доступ |
|---|---|
| `catalog:read` | Чтение каталога |
| `cart:write` | Изменение корзины |
| `order:read` | Чтение заказов |
| `admin:*` | Полный доступ (только для staff) |

Подробно: [./auth.md](./auth.md).

## Rate limits

| Endpoint | Лимит |
|---|---|
| Catalog read | 1000 req/min на токен |
| Checkout | 60 req/min на пользователя |
| Auth | 10 req/min на IP |

При превышении — `429 Too Many Requests` с `Retry-After`.

## Версионирование

URL-based: `/api/v1`, `/api/v2`. Breaking changes — новый major.

## OpenAPI

Полная спецификация: [./openapi.yaml](./openapi.yaml).

## Документация по endpoint-ам

- [POST /api/v1/orders — создание заказа](./checkout-create-order.md)
- (другие — генерируются из OpenAPI)

## Связанное

- [Архитектурный обзор](../arch/overview.md)
- [ADR-0001: PostgreSQL](../adr/0001-use-postgres.md)
