---
type: standard
title: Каноническая структура каталогов
status: approved
---

# Каноническая структура каталогов

Каждый продукт в `C:\src\products\<product>/` обязан иметь следующее дерево. Лишние папки — удалять, отсутствующие обязательные — создавать.

## Полное дерево

```
<Product>/
├── README.md                      # точка входа в продукт (что это, как запустить)
├── CHANGELOG.md                   # верхнеуровневый changelog (ссылается на docs/releases/)
├── LICENSE.md                     # лицензия (если применимо)
│
├── docs/                          # ВСЯ внутренняя документация
│   ├── INDEX.md                   # манифест (генерируется, не редактируется руками)
│   │
│   ├── manual/                    # руководство пользователя / администратора
│   │   ├── ru/                    # русская локаль
│   │   └── en/                    # английская локаль (если есть)
│   │
│   ├── help/                      # статьи in-app справки (короткие, task-oriented)
│   │   ├── ru/
│   │   └── en/
│   │
│   ├── tech/                      # технические документы для разработчиков
│   │   ├── getting-started.md
│   │   ├── architecture-overview.md
│   │   ├── data-model.md
│   │   ├── integrations.md
│   │   └── ...
│   │
│   ├── arch/                      # диаграммы и описания архитектуры (человекочитаемое)
│   │   ├── overview.md
│   │   ├── components.md
│   │   └── diagrams/
│   │
│   ├── adr/                       # Architectural Decision Records (Nygard format)
│   │   ├── 0001-use-postgres.md
│   │   ├── 0002-event-driven-jobs.md
│   │   └── README.md              # индекс ADR
│   │
│   ├── api/                       # API reference
│   │   ├── openapi.yaml           # машинный контракт
│   │   ├── README.md              # человекочитаемый обзор
│   │   └── auth.md
│   │
│   ├── runbook/                   # для on-call / ops
│   │   ├── incident-response.md
│   │   ├── backup-restore.md
│   │   └── ...
│   │
│   ├── releases/                  # release notes
│   │   ├── 2026-09-01-v1.2.0.md
│   │   ├── 2026-08-15-v1.1.0.md
│   │   └── README.md              # сводный changelog
│   │
│   ├── roadmap/                   # что планируем
│   │   ├── 2026-q4.md
│   │   └── themes.md
│   │
│   └── design/                    # дизайн-система (для продукта)
│       ├── design-tokens.md
│       ├── components.md
│       └── patterns.md
│
├── marketing/                     # ВСЯ внешняя документация
│   ├── INDEX.md                   # манифест
│   ├── positioning.md             # позиционирование, УТП
│   ├── pitch.md                   # питч (elevator + extended)
│   ├── personas.md                # персоны
│   ├── competitive.md             # конкурентный анализ
│   │
│   ├── showcase/                  # витрина: кейсы, скриншоты, демо-сценарии
│   │   ├── README.md
│   │   ├── <feature>-demo.md
│   │   └── screenshots/
│   │
│   ├── hero/                      # hero-медиа (видео, ключевые визуалы)
│   │   ├── README.md
│   │   ├── final/
│   │   ├── prompts/
│   │   └── rejected/
│   │
│   ├── campaigns/                 # маркетинговые кампании
│   │   └── YYYY-MM-<slug>/
│   │
│   └── brand/                     # бренд-гайд, логотипы, цвета, типографика
│       ├── logo/
│       ├── colors.md
│       └── typography.md
│
├── mockups/                       # визуальные макеты (Figma-export, скетчи)
│   ├── README.md
│   ├── themes/
│   └── flows/
│
├── media/                         # медиа-библиотека (общая)
│   ├── brand/
│   ├── assets/
│   └── icons/
│
├── tracking/                      # таск-трекер (не меняем, это уже канон)
│   ├── bugs/
│   ├── tasks/
│   └── epics/
│
├── src/                           # код (не трогаем этим стандартом)
├── tests/
├── deploy/
├── scripts/
└── ...
```

## Обязательные vs опциональные папки

| Папка | Обязательна | Комментарий |
|---|---|---|
| `README.md` (корень) | ✅ да | Точка входа. Один экран: что это, кому, как запустить, куда дальше. |
| `docs/INDEX.md` | ✅ да | Генерируется из frontmatter всех файлов в `docs/`. |
| `docs/manual/` | ⚠️ для продуктов с клиентами | Если продуктом пользуются люди — должно быть. Внутренние тулзы — не нужно. |
| `docs/help/` | ⚠️ для продуктов с UI | Если есть UI — должны быть help-статьи. |
| `docs/tech/` | ✅ да | Всегда. Даже если один файл — `getting-started.md`. |
| `docs/arch/` | ⚠️ для серьёзных продуктов | Если >5 модулей или есть внешние интеграции — обязательно. |
| `docs/adr/` | ⚠️ для продуктов >3 разработчиков | ADR обязательны, если есть архитектурные решения, которые будут пересматриваться. |
| `docs/api/` | ⚠️ если есть публичный API | OpenAPI + README. |
| `docs/runbook/` | ⚠️ если есть прод | On-call и бэкапы — обязательно. |
| `docs/releases/` | ✅ да | Хотя бы `README.md` со ссылками. |
| `docs/roadmap/` | ✅ да | Хотя бы `themes.md` с текущим кварталом. |
| `docs/design/` | ⚠️ если есть UI | Дизайн-система отдельно от кода. |
| `marketing/INDEX.md` | ✅ да | Даже если пусто — INDEX обязателен. |
| `marketing/positioning.md` | ⚠️ если продукт продаётся | Питч и позиционирование. |
| `marketing/showcase/` | ⚠️ если продукт публичный | Витрина для сейлзов и партнёров. |
| `marketing/hero/` | ⚠️ если есть лендинг | Hero-видео и ключевые визуалы. |
| `marketing/brand/` | ⚠️ если есть бренд | Лого, цвета, типографика. |
| `mockups/` | ⚠️ если есть UI | Сюда — Figma-export, скриншоты прототипов. |
| `media/` | ✅ да | Общая медиа-библиотека. |

## Запрещённые имена

- ❌ `docs/old/`, `docs/archive/`, `docs/v1/`, `docs/legacy/` → статус `deprecated` в frontmatter
- ❌ `docs/misc/`, `docs/stuff/`, `docs/temp/` → не существует, разнеси по типам
- ❌ `docs/manual-staff.md`, `docs/manual-parent.md` → `docs/manual/{role}/{topic}.md`
- ❌ `docs/knowledge-base.md` (один файл на 148 КБ) → разбить на `docs/help/{locale}/{topic}.md`
- ❌ `docs/technical-specification.md` → `docs/tech/architecture-overview.md` или разбить
- ❌ `docs/hero-video.md` → `marketing/hero/README.md`
- ❌ `frontend/src/help/...` → `docs/help/...` (справка не в коде)
- ❌ Нумерованные префиксы `01-`, `02-` → папки по теме, не по номеру

## Что НЕ входит в стандарт

- `src/`, `tests/`, `deploy/`, `scripts/` — это код и инфра, у них свои конвенции.
- `tracking/` — уже канонизирован отдельно, не трогаем.
- `.claude/`, `.codegraph/`, `.forgejo/`, `.omo/`, `.ai/`, `.opencode/` — рабочие папки инструментов, не документы.
- `node_modules/`, `bin/`, `obj/`, `dist/`, `build/` — служебные.
