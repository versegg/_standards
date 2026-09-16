---
type: adr
title: ADR-0002. Фоновые задачи через Redis Streams
status: accepted
owner: tech-lead
last_reviewed: 2026-07-12
version: 1
tags: [jobs, redis, decision]
related:
  - ../arch/overview.md
supersedes: []
superseded_by: []
---

# ADR-0002. Фоновые задачи через Redis Streams

## Статус

`accepted` на 2025-02-04.

## Контекст

В Shop много фоновых задач: фискализация чеков, отправка email/SMS, резервирование, синхронизация с 1С, обновление поискового индекса. Нужна инфраструктура, которая:

- поддерживает at-least-once доставку;
- позволяет retry с backoff;
- не требует отдельного кластера (мы уже используем Redis для кэша);
- даёт возможность отложенного запуска (delayed jobs).

## Решение

Используем **Redis Streams** как очередь задач. Отдельный модуль `Shop.Jobs.Redis`.

- Консьюмеры: `Shop.Jobs.Redis` worker-ы, по одному на тип задачи.
- Retry: exponential backoff, до 5 попыток, потом — в dead-letter stream.
- Delayed jobs: ключ сортировки по timestamp в отдельном stream.
- Мониторинг: длина streams в Grafana.

### Положительные последствия

- Не нужен отдельный кластер (Kafka/RabbitMQ).
- Простая модель: producer/consumer + XADD/XREADGROUP.
- Уже есть Redis в инфраструктуре.

### Отрицательные последствия

- Нет встроенной exactly-once — полагаемся на идемпотентность обработчиков.
- Ограничения по размеру payload (≤512 MB на запись, но мы держим <10 KB).
- Если вырастем до очень больших объёмов — возможно придётся мигрировать на Kafka.

## Альтернативы

### RabbitMQ

- Плюсы: зрелая, богатый routing.
- Минусы: ещё один сервис в проде, ещё одна точка отказа.
- Почему не выбрали: оверкилл для текущего объёма.

### Kafka

- Плюсы: масштабируется, retention, replay.
- Минусы: тяжёлая инфраструктура, нужны эксперты.
- Почему не выбрали: нет объёмов, оправдывающих Kafka. Пересмотрим, если RPS вырастет x10.

### Hangfire на Postgres

- Плюсы: ничего нового в инфраструктуре.
- Минусы: нагрузка на OLTP-БД, ограниченный throughput.
- Почему не выбрали: фискализация в пиках создаст нагрузку на основную БД.

## Ссылки

- [arch/overview.md](../arch/overview.md)
- [runbook/incident-response.md](../runbook/incident-response.md)
