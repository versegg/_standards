---
type: standard
title: Гайд миграции существующего продукта
status: approved
---

# Гайд миграции существующего продукта

Пошаговый план перевода продукта с текущего состояния на стандарт. Делай один продукт за раз.

## Фаза 0. Инвентаризация (1–2 часа)

```powershell
# Собрать все .md в продукте
Get-ChildItem -Path "C:\src\products\<product>" -Recurse -File -Filter "*.md" |
  Where-Object { $_.FullName -notmatch 'node_modules|\.git|bin|obj|dist|build' } |
  Select-Object FullName, Length |
  Export-Csv "C:\temp\<product>-docs-inventory.csv" -NoTypeInformation
```

Заполнить таблицу:

| Текущий файл/папка | Содержимое (1 строка) | Новый type | Новый путь |
|---|---|---|---|

## Фаза 1. Создать каноническую структуру (1 час)

Создать пустые папки по [STRUCTURE.md](./STRUCTURE.md):

```powershell
$product = "shop"
$root = "C:\src\products\$product"
$dirs = @(
  "docs\manual\ru","docs\manual\en",
  "docs\help\ru","docs\help\en",
  "docs\tech","docs\arch","docs\adr",
  "docs\api","docs\runbook",
  "docs\releases","docs\roadmap","docs\design",
  "marketing\showcase","marketing\hero","marketing\campaigns","marketing\brand"
)
$dirs | ForEach-Object { New-Item -ItemType Directory -Force -Path "$root\$_" | Out-Null }
```

## Фаза 2. Классифицировать существующие файлы (2–4 часа)

Для каждого файла из инвентаризации решить:

1. **Какой это type?** По [DOC-TYPES.md](./DOC-TYPES.md).
2. **Какой новый путь?** По правилам именования.
3. **Нужен ли перевод на новую структуру?** (Разбить `knowledge-base.md` на 20 help-статей.)

Примеры для shop:

| Было | Стало |
|---|---|
| `docs/README.md` | `docs/INDEX.md` (перегенерировать) + новый корневой `README.md` в корне продукта |
| `docs/roadmap.md` | разбить на `docs/roadmap/themes.md` + `docs/roadmap/2026-q4.md` |
| `docs/technical-specification.md` | разбить на `docs/tech/architecture-overview.md` + `docs/tech/data-model.md` + `docs/tech/integrations.md` |
| `docs/market-research.md` | `marketing/positioning.md` + `marketing/competitive.md` |
| `docs/knowledge-base.md` | разбить на `docs/help/ru/<task>.md` |
| `docs/arch/01-adrs.md` | разбить на `docs/adr/0001-...md`, `0002-...md` |
| `docs/arch/02-kernel-extension-plan.md` | `docs/tech/kernel-extension.md` |
| `docs/arch/03-module-dependencies.md` | `docs/arch/components.md` |
| `docs/arch/04-deployment.md` | `docs/runbook/deployment.md` |
| `docs/arch/05-compliance-architecture.md` | `docs/arch/compliance.md` |
| `docs/arch/06-roadmap.md` | удалить (объединить с `docs/roadmap/`) |
| `docs/design/01-design-system.md` | `docs/design/design-system.md` |
| `docs/design/02-palettes.md` | `docs/design/design-tokens.md` |
| `docs/design/03-theme-packs.md` | `docs/design/themes.md` |
| `docs/design/04-page-constructor-blocks.md` | `docs/design/patterns.md` |
| `marketing/showcase/` | оставить, но добавить `marketing/showcase/README.md` |

Примеры для academy:

| Было | Стало |
|---|---|
| `docs/deployment.md` | `docs/runbook/deployment.md` |
| `docs/features.md` | `docs/tech/features.md` |
| `docs/handover.md` | `docs/runbook/handover.md` |
| `docs/hero-video.md` | удалить (контент в `marketing/hero/`) |
| `docs/manual-parent.md` | `docs/manual/ru/parent/<topic>.md` (разбить на 5–8 файлов) |
| `docs/manual-staff.md` | `docs/manual/ru/staff/<topic>.md` (разбить) |
| `docs/roadmap.md` | `docs/roadmap/themes.md` + `docs/roadmap/2026-q4.md` |
| `docs/site-modes.md` | `docs/tech/site-modes.md` |
| `media/hero/` | переместить в `marketing/hero/` |
| `mockups/themes/` | оставить (canonical) |
| `marketing/showcase/` | оставить + добавить `marketing/showcase/README.md` |

Примеры для veterinary:

| Было | Стало |
|---|---|
| `frontend/src/help/...` | перенести в `docs/help/ru/...` |
| `docs/` (нет) | создать по [STRUCTURE.md](./STRUCTURE.md) |

Примеры для cafe:

| Было | Стало |
|---|---|
| `docs/concerns.md` | `docs/arch/overview.md` или `marketing/positioning.md` (по смыслу) |
| `docs/domain-model.md` | `docs/tech/data-model.md` |
| `docs/end-users.md` | `marketing/personas.md` |
| `docs/market.md` | `marketing/positioning.md` |
| `docs/project-structure.md` | `docs/tech/getting-started.md` |
| `docs/reference-projects.md` | `marketing/competitive.md` |
| `docs/reuse-notes.md` | `docs/tech/reuse.md` |
| `docs/roadmap.md` | `docs/roadmap/themes.md` + `docs/roadmap/2026-q4.md` |
| `docs/site-structure.md` | `docs/arch/overview.md` |
| `marketing/` (нет) | создать по [STRUCTURE.md](./STRUCTURE.md) |

## Фаза 3. Перенести и переименовать (4–8 часов)

```powershell
# Пример: перенос с переименованием
Move-Item "C:\src\products\shop\docs\technical-specification.md" `
         "C:\src\products\shop\docs\tech\architecture-overview.md"
```

После переноса добавить frontmatter по [FRONTMATTER.md](./FRONTMATTER.md). Использовать соответствующий шаблон из [templates/](./templates/).

## Фаза 4. Разбить «жирные» файлы

Большие файлы (>50 КБ) почти наверняка надо разбить:

- `knowledge-base.md` (148 КБ) → `docs/help/ru/<task>.md`, по одной статье на тему
- `manual-staff.md` (147 КБ) → `docs/manual/ru/staff/<topic>.md`
- `roadmap.md` (78–178 КБ) → `docs/roadmap/<year-q>.md` + `docs/roadmap/themes.md`

Правило: один файл — 1–3 экрана. Если больше — это сборник, и его место в `INDEX.md`, а не отдельный файл.

## Фаза 5. Добавить frontmatter везде

Для каждого `.md` под `docs/`, `marketing/`, `mockups/`:

1. Открыть файл.
2. Добавить YAML-блок в начало (см. шаблоны).
3. Заполнить обязательные поля.

## Фаза 6. Сгенерировать INDEX.md

```powershell
.\tools\gen-index.ps1 -Product shop
```

Проверить руками, что сгенерированный INDEX читаемый.

## Фаза 7. Обновить корневой README.md

Заменить текущий `README.md` (если есть) на шаблон из [CROSS-LINKS.md](./CROSS-LINKS.md#корневой-readmemd-продукта).

## Фаза 8. Валидация

```powershell
.\tools\validate.ps1 -Product shop
```

Исправить все ошибки. Warnings — по возможности.

## Фаза 9. Deprecate старые пути

Если старый путь нельзя удалить (внешние ссылки, история):

1. Создать redirect-файл с frontmatter `status: deprecated` и `supersedes: <новый путь>`.
2. Удалить реальный контент.
3. Валидатор пометит как deprecated и не покажет в INDEX.

Пример redirect-файла:

```markdown
---
type: tech
title: Техническая спецификация (DEPRECATED)
status: deprecated
owner: backend-team
last_reviewed: 2026-09-16
superseded_by: tech/architecture-overview.md
---

# Перенесено

Этот документ разделён на:

- [Архитектурный обзор](tech/architecture-overview.md)
- [Модель данных](tech/data-model.md)
- [Интеграции](tech/integrations.md)
```

## Фаза 10. Коммит и анонс

```powershell
git add .
git commit -m "docs(shop): migrate to unified documentation standard

- Разбит knowledge-base.md на 20 help-статей
- Выделен API в docs/api/
- Разнесены ADR в docs/adr/0001-...
- Сгенерированы INDEX.md"
```

Анонсировать в чате команды: «Продукт X переведён на стандарт. Правила — в `_standards/README.md`».

## Чек-лист «миграция завершена»

См. [CHECKLIST.md](./CHECKLIST.md).
