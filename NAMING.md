---
type: standard
title: Соглашение об именовании
status: approved
---

# Соглашение об именовании

## Файлы

| Что | Правило | Пример |
|---|---|---|
| Markdown | `kebab-case.md` | `getting-started.md`, `incident-response.md` |
| Markdown с датой | `YYYY-MM-DD-<slug>.md` | `2026-09-01-v1.2.0.md` |
| ADR | `NNNN-<kebab-slug>.md` (NNNN — 4 цифры, с ведущими нулями) | `0001-use-postgres.md` |
| OpenAPI | `openapi.yaml` или `<service>.openapi.yaml` | `checkout.openapi.yaml` |
| Изображения | `kebab-case.<ext>` | `checkout-flow.png`, `hero-final.jpg` |
| Видео | `kebab-case.<ext>` или `YYYY-MM-DD-<slug>.<ext>` | `checkout-demo.mp4` |

## Папки

| Что | Правило | Пример |
|---|---|---|
| Любая | `kebab-case/` | `docs/manual/`, `marketing/showcase/` |
| Локаль | ISO 639-1 (2 буквы) | `ru/`, `en/` |
| Роль (manual) | `kebab-case/` | `admin/`, `manager/`, `customer/` |
| Дата | `YYYY-MM-DD/` | `2026-09-01/` |
| Год-месяц | `YYYY-MM/` | `2026-09/` |
| Кампания | `YYYY-MM-<slug>/` | `2026-09-launch/` |

## Запрещено

- ❌ `snake_case` или `camelCase` в именах файлов и папок
- ❌ Пробелы в именах (используй `-`)
- ❌ Заглавные буквы (кроме аббревиатур: `API`, `ADR`, `DB`, `UI`, `PWA` — но не в имени файла)
- ❌ Префиксы нумерации `01-`, `02-` — порядок задаётся датой или `sort_order` в frontmatter
- ❌ Префиксы локали `ru-`, `en-` — локаль выносится в подпапку
- ❌ Имена типа `temp`, `misc`, `stuff`, `old`, `new`, `final2` — описательно
- ❌ Версия в имени файла (кроме release notes и ADR) — версия в frontmatter

## Специальные файлы

| Файл | Назначение |
|---|---|
| `README.md` | Точка входа. В каждой значимой папке может быть один. |
| `INDEX.md` | Манифест папки. Генерируется автоматически из frontmatter. Не писать руками. |
| `CHANGELOG.md` | Верхнеуровневый changelog продукта (живёт в корне продукта). |
| `LICENSE.md` | Лицензия (в корне). |

## Сортировка

`INDEX.md` сортирует документы по:

1. `sort_order` в frontmatter (если задан)
2. По алфавиту `title`
3. По пути файла

Для roadmap — по дате квартала (`2026-q4` после `2026-q3`).
Для releases — по убыванию даты.
Для ADR — по возрастанию номера.

## Миграция существующих имён

| Сейчас | Стало |
|---|---|
| `01-adrs.md` | разбить на `docs/adr/0001-...md`, `0002-...md` |
| `manual-staff.md` | `docs/manual/ru/staff/getting-started.md` (или разбить на темы) |
| `manual-parent.md` | `docs/manual/ru/parent/getting-started.md` |
| `knowledge-base.md` | разбить на `docs/help/ru/<task>.md` |
| `technical-specification.md` | разбить на `docs/tech/architecture-overview.md`, `docs/tech/data-model.md`, `docs/tech/integrations.md` |
| `hero-video.md` | удалить (контент в `marketing/hero/`) |
| `market-research.md` | `marketing/positioning.md` + `marketing/competitive.md` |
| `end-users.md` | `marketing/personas.md` |
| `concerns.md` | `docs/arch/overview.md` (если про архитектуру) или `marketing/positioning.md` (если про бизнес) |
