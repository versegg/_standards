---
type: standard
title: Каталог типов документов
status: approved
---

# Каталог типов документов

Каждый документ в продукте имеет ровно один `type` (из YAML-frontmatter). Ниже — полный каталог.

## 1. `manual` — руководство пользователя

**Где:** `docs/manual/<locale>/<role>/<topic>.md`
**Аудитория:** конечный пользователь продукта (клиент, администратор, менеджер)
**Тон:** простой, пошаговый, со скриншотами
**Размер:** один файл — 1–3 экрана; серия — 5–15 файлов
**Локаль:** `ru` обязательно, `en` если есть англоязычные клиенты

Структура внутри `docs/manual/`:
```
manual/
├── ru/
│   ├── admin/           # для администратора системы
│   ├── manager/         # для менеджера/оператора
│   └── customer/        # для конечного клиента (если есть B2C)
└── en/
    └── ...
```

**Когда писать:** при появлении новой пользовательской фичи. **Когда обновлять:** при изменении UI-флоу.

Шаблон: [templates/manual.md](./templates/manual.md)

## 2. `help` — статья in-app справки

**Где:** `docs/help/<locale>/<task>.md`
**Аудитория:** пользователь, который прямо сейчас в интерфейсе и не понимает кнопку
**Тон:** кратко, task-oriented, «как сделать X»
**Размер:** 0.5–1.5 экрана, идеально для боковой панели/tooltip
**Локаль:** `ru` + `en`

Структура:
```
help/
├── ru/
│   ├── checkout-payment.md
│   ├── reset-password.md
│   └── ...
└── en/
    └── ...
```

**Когда писать:** при появлении непонятного UX. **Когда НЕ писать:** если уже есть `manual/`-статья на ту же тему — линкуй из help на manual.

Шаблон: [templates/help-article.md](./templates/help-article.md)

## 3. `tech` — технический документ

**Где:** `docs/tech/<topic>.md`
**Аудитория:** разработчик, который впервые открывает репо
**Тон:** технический, со схемами, ссылками на код
**Размер:** 2–10 экранов

Что сюда писать:
- `getting-started.md` — как поднять локально, какие сервисы нужны, как запустить тесты
- `architecture-overview.md` — верхнеуровневая архитектура (сюда же ссылается `arch/`)
- `data-model.md` — основные сущности и связи
- `integrations.md` — внешние сервисы, API-ключи, контракты
- `testing.md` — как запускать тесты, как писать новые
- `deployment.md` — как деплоить (без on-call — это runbook)
- `security.md` — auth, secrets, threat model
- `performance.md` — узкие места, профилирование

Шаблон: [templates/tech-doc.md](./templates/tech-doc.md)

## 4. `arch` — архитектура (человекочитаемая)

**Где:** `docs/arch/<topic>.md`
**Аудитория:** senior-разработчик, техлид, новый архитектор
**Тон:** концептуальный, с диаграммами
**Отличие от `tech`:** `arch` — это «почему так», `tech` — «как работает»

Структура:
```
arch/
├── overview.md
├── components.md
├── data-flow.md
└── diagrams/
    ├── context.png
    ├── containers.png
    └── components.png
```

Шаблон: [templates/arch-overview.md](./templates/arch-overview.md)

## 5. `adr` — Architectural Decision Record

**Где:** `docs/adr/<NNNN>-<kebab-slug>.md`
**Аудитория:** вся команда разработки + будущие разработчики
**Формат:** Nygard (Michael Nygard), строгий шаблон
**Именование:** строго нумерация — `0001-use-postgres.md`, `0002-event-driven-jobs.md`

Шаблон: [templates/adr.md](./templates/adr.md)

**Когда писать ADR:** когда решение
- дорого отменить;
- влияет на >1 модуль;
- имеет >1 альтернативу, и выбор не очевиден;
- будет пересматриваться через год.

## 6. `api` — API reference

**Где:** `docs/api/`
**Аудитория:** внешний интегратор, фронт, мобильный разработчик
**Содержимое:**
- `openapi.yaml` — машинный контракт (OpenAPI 3.1)
- `README.md` — человекочитаемый обзор: auth, базовый URL, rate-limits, ошибки
- `<resource>.md` — отдельные гайды по ресурсам

Шаблон: [templates/api-endpoint.md](./templates/api-endpoint.md)

## 7. `runbook` — операционный документ

**Где:** `docs/runbook/<scenario>.md`
**Аудитория:** on-call инженер в 3 часа ночи
**Тон:** команды, чек-листы, без рассуждений
**Принцип:** каждая команда должна быть выполнима копипастой

Что сюда:
- `incident-response.md` — что делать, когда пришёл алерт
- `backup-restore.md` — как восстановить из бэкапа
- `db-migration-emergency.md` — откат миграции
- `feature-flag-rollback.md` — выключить фичу-флаг

Шаблон: [templates/runbook.md](./templates/runbook.md)

## 8. `release` — release notes

**Где:** `docs/releases/YYYY-MM-DD-v<MAJOR>.<MINOR>.<PATCH>.md`
**Аудитория:** все — клиенты, поддержка, разработка
**Один релиз = один файл**
**Индекс:** `docs/releases/README.md` — сводный changelog с ссылками на релизы

Шаблон: [templates/release-note.md](./templates/release-note.md)

## 9. `roadmap` — roadmap

**Где:** `docs/roadmap/YYYY-Q<n>.md` или `docs/roadmap/themes.md`
**Аудитория:** команда, стейкхолдеры
**Тон:** кратко, без обещаний конкретных дат

Структура:
```
roadmap/
├── README.md           # что такое roadmap, как читать
├── themes.md           # долгосрочные направления
├── 2026-q4.md          # текущий квартал
├── 2027-q1.md          # следующий квартал
└── backlog.md          # идеи без квартала
```

Шаблон: [templates/roadmap-item.md](./templates/roadmap-item.md)

## 10. `design` — дизайн-система продукта

**Где:** `docs/design/`
**Аудитория:** дизайнер, фронт
**Отличие от `mockups/`:** `design/` — это токены, компоненты, паттерны (повторно используемое); `mockups/` — конкретные макеты конкретных экранов

Структура:
```
design/
├── design-tokens.md    # цвета, отступы, типографика
├── components.md       # каталог компонентов
├── patterns.md         # паттерны (формы, навигация, ошибки)
└── accessibility.md    # a11y-гайдлайны
```

Шаблон: [templates/design-spec.md](./templates/design-spec.md)

## 11. `positioning` — позиционирование продукта

**Где:** `marketing/positioning.md`
**Аудитория:** сейлз, маркетинг, фаундер
**Содержимое:** кто клиент, какая боль, как мы решаем, чем отличаемся, УТП в одно предложение

Шаблон: [templates/marketing-positioning.md](./templates/marketing-positioning.md)

## 12. `pitch` — питч

**Где:** `marketing/pitch.md`
**Аудитория:** инвестор, партнёр, сейлз на звонке
**Содержимое:** elevator (30 сек), extended (3 мин), demo script, FAQ по возражениям

Шаблон: [templates/marketing-pitch.md](./templates/marketing-pitch.md)

## 13. `showcase` — витрина

**Где:** `marketing/showcase/<feature>-demo.md` + `marketing/showcase/screenshots/`
**Аудитория:** потенциальный клиент, партнёр, журналист
**Содержимое:** скриншоты фичи, демо-сценарий, видео-gif, ссылка на живое демо

Шаблон: [templates/showcase-item.md](./templates/showcase-item.md)

## 14. `hero` — hero-медиа

**Где:** `marketing/hero/`
**Аудитория:** посетитель лендинга
**Содержимое:** финальные видео/изображения, промпты для генерации, отклонённые варианты

Структура:
```
hero/
├── README.md           # что это, какой сейчас актуален
├── final/              # то, что публикуется
├── prompts/            # промпты для генерации (Midjourney, Sora, etc.)
└── rejected/           # варианты, которые не зашли
```

## 15. `campaign` — маркетинговая кампания

**Где:** `marketing/campaigns/YYYY-MM-<slug>/`
**Содержимое:** бриф, целевая аудитория, каналы, креативы, метрики успеха

## 16. `brand` — бренд-гайд

**Где:** `marketing/brand/`
**Содержимое:** лого, цвета, типографика, тон коммуникации

## 17. `mockup` — визуальный макет

**Где:** `mockups/themes/<theme>.md` или `mockups/flows/<flow>.md`
**Аудитория:** дизайнер, продукт-менеджер
**Содержимое:** ссылка на Figma, экспортнутые PNG, текстовое описание

Шаблон: [templates/mockup-caption.md](./templates/mockup-caption.md)

## Сводная таблица

| type | Где | Аудитория | Шаблон |
|---|---|---|---|
| `manual` | `docs/manual/<locale>/<role>/` | Клиент | [link](./templates/manual.md) |
| `help` | `docs/help/<locale>/` | Клиент в UI | [link](./templates/help-article.md) |
| `tech` | `docs/tech/` | Разработчик | [link](./templates/tech-doc.md) |
| `arch` | `docs/arch/` | Архитектор | [link](./templates/arch-overview.md) |
| `adr` | `docs/adr/` | Вся команда | [link](./templates/adr.md) |
| `api` | `docs/api/` | Интегратор | [link](./templates/api-endpoint.md) |
| `runbook` | `docs/runbook/` | On-call | [link](./templates/runbook.md) |
| `release` | `docs/releases/` | Все | [link](./templates/release-note.md) |
| `roadmap` | `docs/roadmap/` | Команда, стейкхолдеры | [link](./templates/roadmap-item.md) |
| `design` | `docs/design/` | Дизайнер, фронт | [link](./templates/design-spec.md) |
| `positioning` | `marketing/positioning.md` | Сейлз, фаундер | [link](./templates/marketing-positioning.md) |
| `pitch` | `marketing/pitch.md` | Инвестор, партнёр | [link](./templates/marketing-pitch.md) |
| `showcase` | `marketing/showcase/` | Клиент, партнёр | [link](./templates/showcase-item.md) |
| `hero` | `marketing/hero/` | Лендинг | (см. STRUCTURE.md) |
| `campaign` | `marketing/campaigns/` | Маркетинг | (см. STRUCTURE.md) |
| `brand` | `marketing/brand/` | Все | (см. STRUCTURE.md) |
| `mockup` | `mockups/` | Дизайнер | [link](./templates/mockup-caption.md) |
| `standard` | `_standards/` | Все | — |
