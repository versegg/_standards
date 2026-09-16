---
type: runbook
title: Восстановление БД из бэкапа
status: approved
owner: ops-team
audience: ops
last_reviewed: 2026-08-20
tags: [database, backup, disaster]
related:
  - ./incident-response.md
  - ../adr/0001-use-postgres.md
---

# Восстановление БД из бэкапа

## Когда применять

- БД недоступна >15 минут и не поднимается стандартными средствами.
- Данные повреждены (подтверждено, не «кажется»).
- Нужен point-in-time recovery.

## Предусловия

- S3-доступ к бэкапам (см. Secrets Vault).
- Права на `kubectl exec` в namespace `shop-prod`.
- Знание, до какой точки восстанавливать (timestamp).

## Действия

### 1. Объявить даунтайм

В Slack `#status` и в стейтус-странице.

### 2. Остановить запись

```bash
kubectl scale deployment/shop-api --replicas=0 -n shop-prod
kubectl scale deployment/shop-jobs --replicas=0 -n shop-prod
```

### 3. Найти нужный бэкап

```bash
aws s3 ls s3://shop-backups/postgres/ --recursive | grep <YYYY-MM-DD>
```

### 4. Скачать бэкап

```bash
aws s3 cp s3://shop-backups/postgres/<backup-file>.dump.gz /tmp/
```

### 5. Создать новый инстанс БД

```bash
./scripts/db/create-restore-instance.sh <YYYY-MM-DD-HH-MM>
```

### 6. Восстановить

```bash
pg_restore -h <new-host> -U postgres -d shop /tmp/<backup-file>.dump
```

### 7. Проверить

```bash
psql -h <new-host> -U postgres -d shop -c "SELECT count(*) FROM orders;"
psql -h <new-host> -U postgres -d shop -c "SELECT max(created_at) FROM orders;"
```

### 8. Переключить приложение

Обновить secret `db-connection-string` в Kubernetes, перезапустить API.

```bash
kubectl set env deployment/shop-api -n shop-prod DB_HOST=<new-host>
kubectl rollout restart deployment/shop-api -n shop-prod
```

### 9. Поднять обратно

```bash
kubectl scale deployment/shop-api --replicas=3 -n shop-prod
kubectl scale deployment/shop-jobs --replicas=2 -n shop-prod
```

### 10. Объявить восстановление

В Slack `#status` и в стейтус-странице.

## Откат

Если восстановление не помогло — переключиться обратно на старый хост и звать DBA.

## Постмортем

Обязателен. RPO/RTO анализ — в постмортем.

## Связанное

- [Incident response](./incident-response.md)
