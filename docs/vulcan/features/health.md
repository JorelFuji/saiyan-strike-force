# Health App Integration

Health is secondary. Training data is primary. See [invariants.md](../invariants.md) (invariants 2, 3, 9).

---

## Product rules

On finish, **enqueue** a sync job. Do not write to Health as a blocking side effect of Finish. If permission is missing, the provider is off, or the write fails, the session is still `finished`.

### What to write (v1)

| Write | v1 |
|---|---|
| Workout / exercise session + duration | Yes |
| Heart rate | Only if a real platform/device source exists — do not invent it |
| Active energy / calories | **No**, unless it comes from a defensible platform/device measurement. Do not estimate from sets/reps/weight |

Apple: default activity type **Traditional Strength Training** (`HKWorkoutActivityType.traditionalStrengthTraining`). Request authorization contextually (first time the user enables the toggle or finishes a session with the toggle on), not at cold start.

Android: `ExerciseSessionRecord` via Health Connect. Check permissions before every use (users can revoke at any time). Use a unique `client_record_id` so retries de-duplicate.

### Local Health-sync outbox

```
health_sync
  id
  session_id
  provider                # apple | google
  state                   # see below
  provider_record_id      nullable
  client_record_id        # stable UUID, idempotency key
  last_attempt_at         nullable
  error_code              nullable
  error_message           nullable
```

Per-provider UI/state:

```
Not enabled
Permission needed
Ready
Pending
Synced
Failed
```

Retries are automatic (with backoff) and manual (from Session Summary / Settings). Pull-to-refresh on History may retry failed jobs; it must never imply that training data lives in Health.

Settings: independent enable/disable per provider. No nutrition, sleep, or other Health domains.

---

## Implementation notes

- Use a maintained Flutter plugin (e.g. `health`) rather than hand-rolled platform channels.
- Confirm Health Connect min SDK / installed-app requirements against current Android docs at implementation time (Android 9+ with Play services; 14+ on-system).
- Unique `client_record_id` on every outbox row; retries must be idempotent.
- Write-only; no read-back in v1, which avoids merge conflicts with future past-session edits.

`HealthSyncService` ownership and layering: [architecture.md](../architecture.md). Table summary: [data-model.md](../data-model.md).
