---
type: standard
title: Frontmatter-схема
status: approved
---

# Frontmatter-схема

Любой `.md` в `docs/`, `marketing/`, `mockups/`, `media/` начинается с YAML-блока. Валидатор `tools/validate.ps1` проверяет схему.

## Полная схема

```yaml
---
type: <см. DOC-TYPES.md>            # ОБЯЗАТЕЛЬНО
title: <человек читаемый заголовок>  # ОБЯЗАТЕЛЬНО
status: draft | review | approved | deprecated   # ОБЯЗАТЕЛЬНО
owner: <ник или роль>               # ОБЯЗАТЕЛЬНО
audience: <см. ниже>                # ОПЦИОНАЛЬНО (выводится из type)
product: <product-slug>             # ОПЦИОНАЛЬНО (если файл вне корня продукта)
locale: ru | en | ...               # ОБЯЗАТЕЛЬНО для manual/help
version: <semver>                   # ОПЦИОНАЛЬНО
last_reviewed: YYYY-MM-DD           # ОБЯЗАТЕЛЬНО, ревью раз в 6 мес
created: YYYY-MM-DD                 # ОПЦИОНАЛЬНО
tags: [<tag>, ...]                  # ОПЦИОНАЛЬНО
related:                            # ОПЦИОНАЛЬНО
  - <относительный путь или внешний URL>
supersedes: <путь>                  # ОПЦИОНАЛЬНО, если этот документ заменил старый
---
```

## Обязательность по типам

| type | status | owner | last_reviewed | locale |
|---|---|---|---|---|
| `manual` | ✅ | ✅ | ✅ | ✅ |
| `help` | ✅ | ✅ | ✅ | ✅ |
| `tech` | ✅ | ✅ | ✅ | — |
| `arch` | ✅ | ✅ | ✅ | — |
| `adr` | ✅ | ✅ | ✅ | — |
| `api` | ✅ | ✅ | ✅ | — |
| `runbook` | ✅ | ✅ | ✅ | — |
| `release` | ✅ | ✅ | ✅ | — |
| `roadmap` | ✅ | ✅ | ✅ | — |
| `design` | ✅ | ✅ | ✅ | — |
| `positioning` | ✅ | ✅ | ✅ | — |
| `pitch` | ✅ | ✅ | ✅ | — |
| `showcase` | ✅ | ✅ | ✅ | — |
| `hero` | ✅ | ✅ | ✅ | — |
| `campaign` | ✅ | ✅ | ✅ | — |
| `brand` | ✅ | ✅ | ✅ | — |
| `mockup` | ✅ | ✅ | ✅ | — |
| `standard` | ✅ | ✅ | ✅ | — |

## Статусы

| status | Значение | Что значит |
|---|---|---|
| `draft` | Черновик | Документ в работе, может быть неполным. Не индексируется в INDEX.md как «готовый». |
| `review` | На ревью | Готов, ждёт ревью владельца или коллеги. |
| `approved` | Утверждён | Канонический, актуальный. Попадает в INDEX.md. |
| `deprecated` | Устарел | Не удаляем (история важна), но не показываем в актуальном INDEX.md. Должно быть поле `supersedes` или `superseded_by`. |

Правила переходов:
- `draft` → `review` → `approved` → `deprecated`
- `deprecated` → `approved` (если вернули в строй, с новым `last_reviewed`)
- Любой → `draft` (если решили переделать)

## Аудитории (`audience`)

| Значение | Кто |
|---|---|
| `customer` | Конечный клиент (B2C) |
| `admin` | Администратор системы |
| `manager` | Менеджер/оператор |
| `developer` | Разработчик |
| `architect` | Архитектор |
| `designer` | Дизайнер |
| `ops` | DevOps / SRE |
| `sales` | Сейлз |
| `marketing` | Маркетинг |
| `founder` | Фаундер, инвестор |
| `partner` | Партнёр, интегратор |
| `support` | Поддержка |
| `all` | Все |

Можно несколько через запятую: `audience: developer, ops`.

## Теги (`tags`)

Свободный словарь, но есть каноны:
- по модулю: `checkout`, `catalog`, `payments`, `auth`
- по теме: `security`, `performance`, `compliance`, `i18n`
- по стадии: `onboarding`, `migration`, `legacy`

## Связи (`related`)

Список путей (относительных или абсолютных URL). Генерируется автоматически, но поддерживается руками. Пример:

```yaml
related:
  - ../../adr/0001-use-postgres.md
  - ../tech/data-model.md
  - https://external.example.com/spec
```

## Версионирование (`version`)

SemVer: `1.2.0`. Ставится, когда документ привязан к конкретной версии продукта (ADR, API, release).

## Примеры

### Минимальный (для tech-документа)

```yaml
---
type: tech
title: Как поднять локально
status: approved
owner: backend-team
last_reviewed: 2026-09-16
---
```

### Полный (для manual-статьи)

```yaml
---
type: manual
title: Настройка каталога товаров
status: approved
owner: product-team
audience: admin, manager
locale: ru
version: 1.2.0
last_reviewed: 2026-09-16
created: 2026-03-10
tags: [catalog, admin, onboarding]
related:
  - ../help/ru/add-product.md
  - ../../tech/data-model.md#catalog
---
```

### ADR

```yaml
---
type: adr
title: ADR-0001. Используем PostgreSQL
status: approved
owner: tech-lead
last_reviewed: 2026-09-16
version: 1
tags: [database, decision]
related:
  - ../arch/overview.md
supersedes: []
superseded_by: []
---
```

## Валидация

Запустить:
```powershell
.\tools\validate.ps1 -Product <slug>
```

Скрипт проверит:
1. Наличие frontmatter во всех `.md` под `docs/`, `marketing/`, `mockups/`.
2. Обязательные поля для каждого `type`.
3. Корректность `status`, `locale` (если применимо).
4. Что все пути в `related` существуют.
5. Что `last_reviewed` не старше 6 месяцев (warning).
6. Что `supersedes` указывает на существующий файл.
