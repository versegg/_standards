---
type: tech
title: Модель данных Shop
status: approved
owner: backend-team
audience: developer
version: 1.2.0
last_reviewed: 2026-09-15
tags: [data-model, database]
related:
  - ../adr/0001-use-postgres.md
  - ../arch/overview.md
---

# Модель данных Shop

## Основные сущности

### Catalog

- `Product` — товар
- `ProductVariant` — вариант (размер, цвет)
- `Category` — категория
- `Taxonomy` — иерархия категорий

### Inventory

- `Stock` — остаток на складе
- `Reservation` — резерв под заказ
- `Movement` — движение (приход/расход)

### Orders

- `Order` — заказ
- `OrderLine` — позиция
- `OrderEvent` — событие жизненного цикла

### Checkout

- `Cart` — корзина
- `Checkout` — сессия оформления
- `Promotion` — промо-акция

### Payments

- `Payment` — платёж
- `Refund` — возврат
- `FiscalReceipt` — фискальный чек

### Profiles

- `Customer` — клиент
- `Address` — адрес
- `Favorite` — избранное

## Связи (упрощённо)

```
Product 1───* ProductVariant 1───* Stock
Order 1───* OrderLine *───1 ProductVariant
Customer 1───* Order
Customer 1───* Address
```

Подробные ER-диаграммы — в `../arch/diagrams/`.

## Связанное

- [Архитектурный обзор](../arch/overview.md)
- [ADR-0001: PostgreSQL](../adr/0001-use-postgres.md)
