---
type: adr
title: ADR index — Shop
status: approved
owner: tech-lead
last_reviewed: 2026-09-16
audience: developer, architect
---

# ADR index — Shop

Architectural Decision Records для продукта Shop.

| Номер | Название | Статус | Дата |
|---|---|---|---|
| [0001](0001-use-postgres.md) | Используем PostgreSQL | accepted | 2024-11-12 |
| [0002](0002-event-driven-jobs.md) | Фоновые задачи через Redis Streams | accepted | 2025-02-04 |

## Как писать новый ADR

1. Скопировать [../../../templates/adr.md](../../../../_standards/templates/adr.md).
2. Номер — следующий по порядку (с ведущими нулями).
3. Имя файла — `NNNN-<kebab-slug>.md`.
4. Статусы: `draft` → `proposed` → `accepted` / `rejected` → `superseded`.
5. Обновить таблицу выше.

## Связанное

- [Архитектурный обзор](../arch/overview.md)
- [Стандарт ADR](../../../../_standards/templates/adr.md)
