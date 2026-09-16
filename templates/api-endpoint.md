---
type: api
title: <Endpoint name>
status: draft
owner: <backend-team>
audience: developer, partner
version: <X.Y.Z>
last_reviewed: YYYY-MM-DD
tags: [<resource>]
related:
  - ./openapi.yaml
---

# <Endpoint name>

## Endpoint

```
POST /api/v1/<resource>
```

## Авторизация

<Тип авторизации, нужный scope/permission>

## Запрос

### Headers

| Header | Required | Описание |
|---|---|---|
| Authorization | да | Bearer <token> |
| Content-Type | да | application/json |

### Body

```json
{
  "field": "value"
}
```

| Field | Type | Required | Описание |
|---|---|---|---|
| field | string | да | ... |

## Ответ

### 200 OK

```json
{
  "id": "..."
}
```

### 400 Bad Request

```json
{
  "error": "validation_error",
  "details": [...]
}
```

### 401 Unauthorized

...

## Rate limits

- <N> запросов в минуту на токен.

## Пример

```bash
curl -X POST https://api.example.com/api/v1/<resource> \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"field": "value"}'
```

## Связанное

- [OpenAPI spec](./openapi.yaml)
- [Auth guide](./auth.md)
