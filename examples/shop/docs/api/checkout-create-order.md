---
type: api
title: POST /api/v1/orders — создание заказа
status: approved
owner: backend-team
audience: developer, partner
version: 1.2.0
last_reviewed: 2026-09-16
tags: [api, orders, checkout]
related:
  - ./README.md
  - ./openapi.yaml
---

# POST /api/v1/orders — создание заказа

## Endpoint

```
POST /api/v1/orders
```

## Авторизация

Bearer token со scope `checkout:write`.

## Запрос

### Headers

| Header | Required | Описание |
|---|---|---|
| Authorization | да | `Bearer <token>` |
| Content-Type | да | `application/json` |
| Idempotency-Key | рекомендуется | UUID, ключ идемпотентности |

### Body

```json
{
  "checkoutId": "ck_01HZX...",
  "paymentMethodId": "pm_yookassa_card",
  "deliveryAddressId": "addr_01HZX...",
  "comment": "Позвоните за час"
}
```

| Field | Type | Required | Описание |
|---|---|---|---|
| checkoutId | string | да | ID сессии оформления |
| paymentMethodId | string | да | ID платёжного метода |
| deliveryAddressId | string | да | ID адреса доставки |
| comment | string | нет | Комментарий к заказу |

## Ответ

### 201 Created

```json
{
  "id": "ord_01HZX...",
  "status": "pending_payment",
  "total": 12500.00,
  "currency": "RUB",
  "paymentUrl": "https://yoomoney.ru/checkout/..."
}
```

### 400 Bad Request

```json
{
  "error": "validation_error",
  "details": [
    { "field": "checkoutId", "code": "required" }
  ]
}
```

### 409 Conflict

Checkout уже использован или истёк.

### 429 Too Many Requests

Rate limit превышен.

## Идемпотентность

Если передан `Idempotency-Key` и заказ с таким ключом уже создан — возвращается тот же `201` с тем же `id`.

## Пример

```bash
curl -X POST https://api.shop.example.com/api/v1/orders \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: $(uuidgen)" \
  -d '{
    "checkoutId": "ck_01HZX...",
    "paymentMethodId": "pm_yookassa_card",
    "deliveryAddressId": "addr_01HZX..."
  }'
```

## Связанное

- [API overview](./README.md)
- [OpenAPI spec](./openapi.yaml)
