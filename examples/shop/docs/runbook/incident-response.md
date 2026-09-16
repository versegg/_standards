---
type: runbook
title: Incident response — что делать когда пришёл алерт
status: approved
owner: ops-team
audience: ops
last_reviewed: 2026-08-20
tags: [incident, on-call]
related:
  - ./db-restore.md
---

# Incident response

## Когда применять

Любой алерт уровня `critical` или `warning` в Grafana.

## Предусловия

- Доступ к прод-кластеру Kubernetes.
- Доступ к Grafana (https://grafana.shop.example.com).
- PagerDuty-аккаунт.

## Действия

### 1. Acknowledge

В PagerDuty нажать **Acknowledge** в течение 5 минут.

### 2. Оценить масштаб

```bash
kubectl get pods -n shop-prod
kubectl get pods -n shop-prod | grep -v Running | grep -v Completed
```

**Критерий эскалации:** если >20% подов в `CrashLoopBackOff` или `Error` — пейджер tech-лида.

### 3. Посмотреть метрики

Grafana → дашборд **Shop / Overview** → раздел с упавшим сервисом.

Типичные вопросы:
- CPU/RAM?
- Latency p95/p99?
- Error rate?

### 4. Посмотреть логи

```bash
kubectl logs -n shop-prod -l app=<service> --tail=200
```

Или Grafana → Explore → сервис.

### 5. Mitigate

Если известный сценарий — открыть соответствующий runbook:
- БД упала → [db-restore.md](./db-restore.md)
- Платёжный провайдер не отвечает → [payment-provider-down.md](./payment-provider-down.md)
- Деплой сломал → [rollback-deploy.md](./rollback-deploy.md)

Если не известный — **откатить последний деплой**:

```bash
kubectl rollout undo deployment/<service> -n shop-prod
```

### 6. Коммуникация

В `#incidents` (Slack) — короткий апдейт каждые 15 минут:

```
[INCIDENT-2026-09-XX] Краткое описание. Что делаем. ETA.
```

### 7. Resolve

Когда метрики вернулись в норму:

1. Закрыть алерт в PagerDuty.
2. Написать апдейт в `#incidents`.
3. Создать задачу на постмортем в `tracking/tasks/`.

## Постмортем

Шаблон: `tracking/postmortems/YYYY-MM-DD-<slug>.md`.

## Связанное

- [DB restore](./db-restore.md)
- [ADR-0002: Redis Streams jobs](../adr/0002-event-driven-jobs.md)
