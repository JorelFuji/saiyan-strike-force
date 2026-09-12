# Technical Architecture

Flutter stack, MVVM layering, and suggested folder structure. Schema: [data-model.md](data-model.md). Health service: [features/health.md](features/health.md).

---

## Stack

| Library | Role | Architectural Layer |
|---------|------|---------------------|
| injectable (with get_it) | Dependency injection via code generation | Core / Infrastructure |
| fpdart | Functional programming (Either, TaskEither) | Domain / Data / ViewModel |
| freezed | Immutable models & sealed state unions | Domain & Presentation |
| flutter_bloc (Cubit) | State management (acting as the ViewModel) | Presentation |
| flutter_secure_storage | Keychain/KeyStore encrypted storage | Data (Security) |
| shared_preferences | Key-value storage for app settings | Data (Preferences) |
| csv | Parsing and exporting tabular CSV data | Data / Utilities |

- **Framework:** Current Flutter **stable** at project init. Pin the **exact** SDK in the repo (e.g. FVM `.fvmrc` or `environment.sdk` plus CI image) and enforce that pin in CI. Spec says "current stable"; builds pin exact; CI enforces exact.
- **State management:** `flutter_bloc` Cubits act as feature ViewModels (`BlocProvider`, `BlocBuilder` / `BlocListener`, `context.read`). Prefer Cubits over full Blocs unless an event stream is required. Do not switch libraries for fashion.
- **Architecture:** MVVM with a thin use-case layer for cross-repository workflows. Do **not** create a huge Cubit per visual widget, and do **not** put a use-case class behind every button.

```
View
  ↓
Feature Cubit (ViewModel)  # UI state + intents for one feature
  ↓
Use-case / service         # only for real workflows: start session (snapshot),
                           # finish session, resume, enqueue/retry Health
  ↓
Repository interfaces
  ↓
Data sources
```

Business rules live in use-cases / domain, not in widgets and not in repositories.

Feature ViewModels (examples):
- `ActiveSessionCubit` — `startSession`, `completeSet`, `updateSet`, `addSet`, `addExercise`, `finishSession`, `resumeSession`, rest-timer intents
- `PlannerCubit`, `HistoryCubit`, `WorkoutsCubit`, `SettingsCubit`

Repositories persist and define transaction boundaries. They do not decide product policy. Prefer `TaskEither` / `Either` from fpdart for fallible operations.

`HealthSyncService` owns the outbox: `HealthKitAdapter` + `HealthConnectAdapter`. Session finish calls the service to enqueue; it never awaits a successful platform write.

```
                    Flutter UI
                       │
                 Cubit / VM
                       │
                 Use-case layer
                       │
              Repository interfaces
                /       |        \
               /        |         \
          SQLite     Health      Settings
          local      sync        / secure store
             │          │
        SQLCipher    HealthKit
                    Health Connect
```

Conceptual data chain (templates are not the center of history):

```
WorkoutTemplate → ScheduleEntry → SessionSnapshot → SessionExercise → SessionSet → HealthSyncJob
```

## Suggested folder structure

```
lib/
  core/
    di/                 # injectable modules, configureDependencies
    error/              # Failure sealed type (Freezed)
    theme/              # tokens for dark + light, neumorphic decorations, typography
    widgets/
    utils/
  data/
    local/              # sqlcipher, preferences, secure_storage, DAOs, migrations
    csv/                # CSV parse/export helpers
    health/             # adapters + outbox worker
    repositories/
  domain/
    models/
    repositories/       # abstract contracts
    usecases/           # start/finish/resume session, export, health enqueue
  features/
    today/
    planner/
    workouts/
    active_session/
    history/
    settings/           # cubit/ + view/
  injection.dart
  main.dart
```
