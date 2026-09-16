---
type: runbook
title: <Сценарий: что делать когда X>
status: approved
owner: <ops-team>
audience: ops
last_reviewed: YYYY-MM-DD
tags: [<scenario>]
related: []
---

# <Сценарий: что делать когда X>

## Когда применять

Симптом / алерт / условие, при котором открываешь этот runbook.

## Предусловия

- Доступ к <production>.
- Права на <X>.

## Действия

### 1. Оценить масштаб

```bash
# Команда для быстрой оценки
kubectl get pods -n <namespace>
```

**Критерий эскалации:** если >X% подов в нерабочем состоянии — пейджер tech-лида.

### 2. Mitigate (немедленно)

```bash
# Команды для быстрого облегчения
```

### 3. Diagnose

```bash
# Логи, метрики, трейсы
```

### 4. Fix

```bash
# Что чиним
```

### 5. Verify

```bash
# Как проверить, что починили
```

## Откат

```bash
# Команда отката
```

## Постмортем

После инцидента — шаблон постмортема в `tracking/postmortems/YYYY-MM-DD-<slug>.md`.

## Связанное

- [Incident response](./incident-response.md)
- [Алерт в мониторинге](<ссылка на Grafana / Prometheus>)
