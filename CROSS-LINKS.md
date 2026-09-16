---
type: standard
title: Правила кросс-ссылок и INDEX.md
status: approved
---

# Правила кросс-ссылок и INDEX.md

## INDEX.md — манифест папки

`INDEX.md` существует в двух местах:

1. `docs/INDEX.md` — для всех файлов под `docs/`
2. `marketing/INDEX.md` — для всех файлов под `marketing/`

`INDEX.md` **никогда не редактируется руками**. Он генерируется из frontmatter всех `.md` в своей папке.

Генератор: `tools/gen-index.ps1`.

### Что попадает в INDEX

- `status: approved` или `status: review` — попадают в основной список.
- `status: draft` — попадают в раздел «Черновики» (внизу, скрыты по умолчанию).
- `status: deprecated` — НЕ попадают (живут в репозитории для истории).

### Структура INDEX

```markdown
# <Product>: Documentation index

> Сгенерировано tools/gen-index.ps1 · YYYY-MM-DD HH:MM

## By type

### Manual (ru)
- [Настройка каталога](manual/ru/admin/catalog-setup.md) — owner: product-team · reviewed: 2026-09-16
- [Приём платежей](manual/ru/admin/payments.md) — owner: product-team · reviewed: 2026-09-16

### Manual (en)
- ...

### Tech
- [Architecture overview](tech/architecture-overview.md) — owner: backend-team · reviewed: 2026-09-10
- ...

### ADR
- [ADR-0001. Use PostgreSQL](adr/0001-use-postgres.md) — owner: tech-lead · reviewed: 2026-08-20
- ...

## Drafts
- [WIP: миграция на Redis 7](tech/migration-redis-7.md) — owner: backend-team · draft since 2026-09-15
```

## Корневой README.md продукта

Живёт в `C:\src\products\<product>/README.md`. Структура:

```markdown
---
type: readme
title: <Product name>
status: approved
owner: <role>
last_reviewed: YYYY-MM-DD
audience: all
---

# <Product name>

<2-3 предложения: что это, для кого>

## Quick start

- Разработчику: [docs/tech/getting-started.md](docs/tech/getting-started.md)
- Администратору: [docs/manual/ru/admin/getting-started.md](docs/manual/ru/admin/getting-started.md)
- Клиенту: [docs/manual/ru/customer/getting-started.md](docs/manual/ru/customer/getting-started.md)

## Документация

- 📚 Вся документация: [docs/INDEX.md](docs/INDEX.md)
- 🎨 Маркетинг и витрина: [marketing/INDEX.md](marketing/INDEX.md)
- 🎨 Макеты: [mockups/README.md](mockups/README.md)

## Разработка

- Архитектура: [docs/arch/overview.md](docs/arch/overview.md)
- API: [docs/api/README.md](docs/api/README.md)
- ADR: [docs/adr/README.md](docs/adr/README.md)
- Деплой: [docs/runbook/](docs/runbook/)

## Статус

- Версия: v1.2.0
- Последний релиз: [2026-09-01](docs/releases/2026-09-01-v1.2.0.md)
- Roadmap: [docs/roadmap/2026-q4.md](docs/roadmap/2026-q4.md)
- Лицензия: [LICENSE.md](LICENSE.md)
```

## Правила ссылок между документами

### Относительные ссылки — да

```markdown
См. [ADR-0001](../adr/0001-use-postgres.md).
Подробнее в [архитектуре](../arch/overview.md#components).
```

### Абсолютные пути от корня продукта — да, но только в `README.md`

```markdown
[документация](docs/INDEX.md)
```

В остальных файлах — относительные.

### Внешние URL — да

```markdown
[OpenAPI spec](https://spec.openapis.org/oas/v3.1.0)
```

### Что запрещено

- ❌ Полные пути от диска: `[link](C:\src\products\shop\docs\tech\foo.md)`
- ❌ Ссылки на файлы вне репозитория без явного указания версии/даты
- ❌ Ломаные ссылки (валидатор ловит)
- ❌ Ссылки на файлы со статусом `deprecated` без явного комментария «устарело»

## Графы связей

`related` в frontmatter используется для:
- автоматических «См. также» в INDEX.md;
- построения графа знаний (`tools/build-graph.ps1` — будущее);
- подсказок в IDE.

Принцип: если документ ссылается на другой или наоборот — оба должны быть в `related` друг друга (генератор проверяет симметрию и предупреждает).

## Перекрёстные ссылки между типами

| Из \ В | manual | help | tech | arch | adr | api | runbook | release | roadmap | design | marketing |
|---|---|---|---|---|---|---|---|---|---|---|---|
| **manual** | ✅ | ✅ | ⚠️ | ⚠️ | — | ⚠️ | — | ⚠️ | — | ⚠️ | ⚠️ |
| **help** | ✅ | ✅ | — | — | — | — | — | — | — | — | — |
| **tech** | — | — | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — |
| **arch** | — | — | ✅ | ✅ | ✅ | — | — | — | — | ✅ | — |
| **adr** | — | — | ✅ | ✅ | ✅ | — | — | — | — | — | — |
| **api** | — | — | ✅ | ✅ | — | ✅ | — | ✅ | — | — | — |
| **runbook** | — | — | ✅ | ✅ | — | — | ✅ | ✅ | — | — | — |
| **release** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **roadmap** | ⚠️ | — | ⚠️ | ⚠️ | ⚠️ | — | — | — | ✅ | — | ⚠️ |
| **design** | — | — | ✅ | — | — | — | — | — | — | ✅ | — |
| **marketing** | ✅ | — | — | — | — | — | — | — | — | — | ✅ |

- ✅ — нормально
- ⚠️ — допустимо, но осторожно (наружу из аудитории)
- — — не делай

Пример: `manual` → `tech` означает, что в пользовательском мануале может быть ссылка на техническую деталь («как это работает внутри»). Допустимо, но не злоупотребляй.

`marketing` → `tech` — запрещено (маркетинг не должен ссылаться на внутренности).
