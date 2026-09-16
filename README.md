---
type: standard
title: Единый стандарт документации продуктов
status: approved
owner: tech-lead
last_reviewed: 2026-09-16
applies_to: все продукты в C:\src\products
---

# Единый стандарт документации продуктов

> «Рельсы», на которые надо поставить все продукты: academy, amb, bigart, cafe, gym, hotel, omo, realty, salon, shop, veterinary и будущие.

## Зачем этот стандарт

Каждый продукт исторически рос в своём стиле. В итоге:

| Что мы хотим найти | Где оно сейчас |
|---|---|
| Мануал для клиента | shop — нет, academy — `docs/manual-staff.md`, cafe — нет |
| Справка (in-app help) | shop — один файл 148 КБ, veterinary — закопана в `frontend/src/help` |
| Технический документ | shop — `docs/technical-specification.md`, cafe — `docs/domain-model.md`, academy — `docs/features.md` |
| Маркетинг | shop — `marketing/`, academy — `marketing/`, cafe — нет |
| Витрина (showcase) | shop — `marketing/showcase`, academy — `marketing/showcase/academy`, veterinary — нет |
| Hero-медиа | academy — `media/hero/`, shop — нет папки, cafe — нет |
| API-референс | shop — частично в коде, остальные — нет |
| Runbook / on-call | нигде |
| ADR | shop — `docs/arch/01-adrs.md` (один файл), остальные — нет |
| Release notes | нигде |
| Roadmap | у всех есть, но в разных местах и форматах |

Этот стандарт фиксирует **один каталог типов**, **одну структуру каталогов**, **один формат frontmatter**, **одни правила нейминга и ссылок** — для всех продуктов сразу.

## Принципы

1. **Один тип документа — одна папка.** Manual — это `docs/manual/`, help — `docs/help/`, маркетинг — `marketing/`. Никаких «manual-staff.md» рядом с `manual-parent.md»».
2. **Audience-first.** Папка = аудитория: `docs/` — внутренние (разработка + ops + product), `marketing/` — внешние (продажи, клиенты, партнёры).
3. **Frontmatter обязателен.** Любой `.md` под `docs/`, `marketing/`, `mockups/` начинается с YAML-блока. Без него валидатор падает.
4. **Локаль — отдельная подпапка.** `manual/ru/`, `manual/en/`. Не префиксы `ru-` в имени файла.
5. **INDEX.md — единственная точка входа.** Генерируется автоматически из frontmatter всех файлов. Никто не пишет его руками.
6. **Статусы вместо папок.** `draft`, `review`, `approved`, `deprecated`. Не плодим `archive/`, `old/`, `v1/` — статус в frontmatter.
7. **Ссылки между типами — только относительные.** `[см. ADR-0001](../../adr/0001-use-postgres.md)`.
8. **Один продукт = один корневой README.md.** Живёт в корне продукта, ссылается на `docs/INDEX.md` и `marketing/INDEX.md`.

## Что входит в стандарт

| Файл | Что описывает |
|---|---|
| [STRUCTURE.md](./STRUCTURE.md) | Каноническое дерево каталогов каждого продукта |
| [DOC-TYPES.md](./DOC-TYPES.md) | Каталог всех типов документов и их назначение |
| [FRONTMATTER.md](./FRONTMATTER.md) | Схема YAML-frontmatter (обязательные и опциональные поля) |
| [NAMING.md](./NAMING.md) | Соглашение об именовании файлов и папок |
| [CROSS-LINKS.md](./CROSS-LINKS.md) | Как ссылаться между документами и генерировать INDEX.md |
| [MIGRATION.md](./MIGRATION.md) | Как мигрировать существующий продукт на стандарт |
| [CHECKLIST.md](./CHECKLIST.md) | Чек-лист «продукт соответствует стандарту» |
| [templates/](./templates/) | Шаблоны для каждого типа документа |
| [examples/](./examples/shop/) | Полностью «причёсанный» пример на продукте shop |
| [tools/](./tools/) | `validate.ps1` и `gen-index.ps1` |

## Какие продукты уже на рельсах

| Продукт | Статус | Что сделать |
|---|---|---|
| academy | 🟡 частично | Разнести `manual-staff.md` (147 КБ) по `docs/manual/`, вытащить hero из `docs/` в `marketing/hero/`, разделить `roadmap.md` (178 КБ) |
| amb | ⚪ не оценивался | Пройти миграцию |
| bigart | ⚪ не оценивался | Пройти миграцию |
| cafe | 🔴 хаос | Нет маркетинга, нет витрины, нет hero; добавить `marketing/`, `docs/manual/` |
| gym | ⚪ не оценивался | Пройти миграцию |
| hotel | ⚪ не оценивался | Пройти миграцию |
| omo | ⚪ не оценивался | Пройти миграцию |
| realty | ⚪ не оценивался | Пройти миграцию |
| salon | ⚪ не оценивался | Пройти миграцию |
| shop | 🟡 частично | Самый зрелый; разбить `knowledge-base.md` (148 КБ) на `docs/help/`, выделить API в `docs/api/`, разнести `arch/01-adrs.md` на `adr/` |
| veterinary | 🔴 хаос | Нет `docs/`, справка закопана в `frontend/src/help`; полная миграция |

Статусы: 🔴 не соответствует · 🟡 частично · 🟢 полностью на рельсах.

## Как применять

### Новый продукт
1. Скопировать дерево из [STRUCTURE.md](./STRUCTURE.md).
2. Скопировать [templates/](./templates/) под нужные типы.
3. Заполнить frontmatter по [FRONTMATTER.md](./FRONTMATTER.md).
4. Прогнать `tools/validate.ps1` и `tools/gen-index.ps1`.

### Существующий продукт
1. Пройти [CHECKLIST.md](./CHECKLIST.md) — понять текущее состояние.
2. Следовать [MIGRATION.md](./MIGRATION.md) — пошаговый план.
3. После миграции прогнать валидатор.

### Изменение стандарта
Любое изменение — PR в `_standards/`. Все продукты обязаны подтянуть в течение спринта.
