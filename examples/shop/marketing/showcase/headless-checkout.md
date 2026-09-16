---
type: showcase
title: Headless checkout — партнёры встраивают оформление заказа в свои приложения
status: approved
owner: marketing
audience: customer, partner, sales
last_reviewed: 2026-09-01
tags: [headless, api, checkout]
related:
  - ../../docs/api/checkout-create-order.md
  - ../positioning.md
---

# Headless checkout

## Что это

Партнёры встраивают оформление заказа Shop в свои приложения (мобильные, партнёрские витрины) через REST API.

## Для кого

- Партнёры, которые хотят продавать товары Shop через свой фронт.
- Мобильные разработчики, делающие приложение для ритейлера.

## Демо

### Сценарий

1. Партнёр открывает свою мобильную витрину.
2. Клиент выбирает товар, нажимает «Купить».
3. Партнёр отправляет `POST /api/v1/orders` с токеном Shop.
4. Shop создаёт заказ, инициирует оплату, фискализирует.
5. Партнёр получает webhook `order.paid`.

### Скриншоты

![Партнёрская витрина](screenshots/partner-storefront.png)
![Оформление заказа](screenshots/checkout.png)
![Webhook в дашборде партнёра](screenshots/partner-webhook.png)

### Видео

[![Headless checkout demo](screenshots/thumb.png)](https://example.com/demo-headless.mp4)

## Живое демо

[Открыть партнёрский демо-стенд →](https://demo-partner.shop.example.com)

## Цифры

- Время интеграции: median 5 дней для партнёра с мобильным приложением.
- GMV через партнёров: ~12% от общего (растёт).

## Связанное

- [API: POST /api/v1/orders](../../docs/api/checkout-create-order.md)
- [Позиционирование](../positioning.md)
