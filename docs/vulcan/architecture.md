# Technical Architecture

Offline-first Flutter MVVM for Vulcan Fitness: Cubits as screen/workflow ViewModels, explicit constructor injection, Drift with encrypted SQLite, and an owned Material 3 design layer.

Schema: [data-model.md](data-model.md). Product contracts: [invariants.md](invariants.md). Active Session: [features/active-session.md](features/active-session.md). Tokens: [design.md](design.md). Export: [features/privacy-export.md](features/privacy-export.md).

> **Stack source of truth.** This file names the v1 architecture and package baseline. Satellite docs (`data-model.md`, Active Session, design, export), onboarding (`README.md`), and the engineering guide (`AGENTS.md`) match this file. If they disagree on stack, DI, errors, persistence engine, settings storage, routing, rest-timer notifications, or UI library, this file wins.

Do not put package version numbers in this document. Constraints live in `pubspec.yaml`; `pubspec.lock` is committed; upgrades are reviewed intentionally.

---

## Framework pin

Use the current Flutter **stable** channel as the product spec. Pin the **exact** SDK in `.fvmrc`, `pubspec.yaml`, and CI, and enforce that pin in CI. Do not restate the numeric pin here.

v1 has no runtime network client, accounts, server sync, or import path. Do not add `http` / `dio` / Firebase or similar to the baseline.

---

## Package baseline

Add a package when the first feature that needs it is implemented. Groupings below are capabilities, not an install-everything checklist.

### Required (core / P0-first)

| Packages / in-repo types | Role |
|---|---|
| `flutter_bloc` Cubit | Screen/workflow ViewModels. Prefer Cubit over Bloc unless an event stream is required. Do not switch libraries for fashion. |
| Constructor injection + `RepositoryProvider` / `MultiRepositoryProvider` / `BlocProvider` | Composition. Cubits are created at route boundaries. **No** `getIt` lookups in widgets or Cubits. |
| `freezed_annotation` + `freezed` / `build_runner` (dev), **selective** | Models and states that benefit from equality / `copyWith`. Not mandatory for every class. |
| In-repo sealed `Result<T>` (`Ok` / `Err`) and typed `Failure` | Fallible domain and data APIs. No `fpdart`. |
| `drift`, native SQLite executor (`NativeDatabase`), `drift_dev`, `sqlite3` with the `sqlite3mc` encryption **source hook** (not a second pub package), `path_provider` / `path` as needed | Encrypted database, typed queries, transactions, reactive streams, tested migrations. |
| `flutter_secure_storage` | Database encryption key only — not settings. |
| `go_router` with `StatefulShellRoute.indexedStack` | Four tabs plus pushed Active Session / Settings / builders. |

### Conditional (when that feature is built)

| Packages / in-repo types | Role |
|---|---|
| `local_auth` | Biometric / PIN app lock when that Settings feature is built. |
| `flutter_local_notifications`, `timezone`, `flutter_timezone` | P0 rest-timer OS alerts and IANA zone at session start. First imported when Active Session / timer work starts. |
| `dart:convert`; optional `json_serializable` for a versioned export DTO; `share_plus` | JSON export delivery via a private temp file and the share sheet. |
| `intl` | Only when formatting needs exceed Flutter built-ins. |
| `bloc_test`, SDK `integration_test` | Tests. Prefer hand-written fakes over a mocking package. |

### Deferred (not in the v1 baseline)

Do **not** add these in v1. Do not leave deprecated aliases (`get_it` wrappers, `fpdart` re-exports, `shared_preferences` “just in case”).

| Packages / kits | Why deferred |
|---|---|
| `injectable`, `get_it` | Explicit constructors and Bloc providers are enough at this app’s size. |
| `fpdart` | In-repo `Result` / `Failure` plus Dart pattern matching. |
| `csv` | JSON is the P0 export format (`dart:convert`). CSV is optional later. |
| `shared_preferences` | SQLite `settings` is the single source of truth. |
| Third-party UI / neumorphism / calendar / form-builder **kits** | Owned Material 3 + `ThemeExtension` + `lib/ui/core`. Selective neumorphic visuals from [design.md](design.md) are in-repo, not a kit. |
| HealthKit / Health Connect packages | [Roadmap](roadmap.md) Decision 3: deferred post-v1. |
| `http`, `dio`, Firebase, or other runtime network clients | Offline-first; no account or server in v1. |

---

## Layering

```
View
  → Cubit (one screen or one workflow)
    → Use case (only StartSession / FinishSession / ResumeSession
       and similar cross-repository workflows)
    → Repository interfaces
      (data consistency, transactions, error translation,
       persistence invariants)
        → Drift database
        → Platform services
          (SecureKeyService, NotificationService,
           TimezoneService, ExportService)
```

Simple CRUD: the Cubit calls one repository. Do not add a pass-through use case behind every button.

A Cubit may depend on **repositories and platform services** (and on use cases when the workflow spans them). Cross-cutting sequences such as “commit `rest_*` then schedule the OS notification” belong in `ActiveSessionCubit` or a small rest-timer use case — not inside the Drift database layer, and not as one Cubit calling another Cubit.

Conceptual data chain (templates are not the center of history):

```
WorkoutTemplate → ScheduleEntry → SessionSnapshot → SessionExercise → SessionSet
```

### Responsibility split

- **Repositories** own transaction boundaries, foreign keys, snapshot writes, retry / error mapping to `Failure`, and persistence invariants (for example: a completed set is committed before success is reported). They are the single source of truth for stored data.
- **Use cases** own product workflow that spans repositories or services: start a session with a template snapshot and optional schedule link in one transaction; finish; resume-on-launch hydration.
- **Services** wrap platform APIs (secure storage, notifications, time zone, share sheet). They are not use cases.
- **Cubits** own UI state and user intents. One Cubit must not depend on another Cubit. Shared durable state comes from repository streams.
- **Widgets** receive Cubits and repositories through constructors or `context.read` of providers created above them. They do not look up a global locator. Do not put `SecureKeyService` on a widget-readable provider unless a screen truly needs it; keep it in the composition root / database constructor.

---

## Dependency injection

One composition root. Target paths (not created in the architecture-docs PR):

- `lib/app/bootstrap.dart` — ordered startup (key → database → migrations → services → resume query → `runApp`)
- `lib/app/dependencies.dart` — construct the database, services, and repositories
- `lib/app/router.dart` — `go_router` shell and route builders
- `lib/app/app.dart` — `MultiRepositoryProvider` around the router

Construct long-lived objects at startup and provide them with `MultiRepositoryProvider`. Create each Cubit in its `go_router` route builder with `BlocProvider` so the route owns disposal.

Do **not** construct `ActiveSessionCubit` in bootstrap and pass it with `BlocProvider.value`. That would make it a process-wide singleton. `BlocProvider.value` is only for a caller that already owns a Cubit on the same route subtree (not used for Active Session).

Do **not** use `injectable` or `get_it` in v1. Do not call a service locator from a widget or a Cubit.

---

## Errors: `Result` and `Failure`

Fallible domain and data APIs return an in-repo sealed `Result<T>`. I/O methods return `Future<Result<T>>`. Watches may return streams of domain objects; map persistence errors to `Failure` at the repository boundary. Do not use `fpdart` `Either` / `TaskEither`.

```dart
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
```

Failures are a sealed hierarchy, for example storage, encryption, validation, and permission. Unknown or corrupt persisted values become `Failure`s, not crashes or silent defaults, unless a specification defines a default.

Handle results with Dart pattern matching at the Cubit / use-case boundary. Surface a visible pending or error state until a write commits.

---

## Cubit scope

Cubits are **screen- or workflow-sized**, not feature-name-sized and not per leaf widget.

Examples:

- `WorkoutListCubit`, `WorkoutBuilderCubit`, `WorkoutDetailCubit` — distinct Workouts screens and lifecycles
- `TodayCubit`, `PlannerCubit`, `HistoryListCubit`, `SessionDetailCubit`, `SettingsCubit` — one screen each
- `ActiveSessionCubit` — one workflow (`completeSet`, `updateSet`, `addSet`, `addExercise`, rest-timer intents, `pauseSession`, `finishSession`, `abandonSession`). Keep this as a single Cubit; do not split it per set row. Session **start** is `StartSession` (see below), not a second insert from the Cubit constructor.

Do not create a Cubit per visual widget. Do not grow one Cubit that owns list, builder, and detail for a whole tab.

### Starting and resuming a session

- **Start** runs exactly once: Today / Planner / freestyle calls `StartSession` (one transaction: snapshot + optional schedule link), then the router **pushes** Active Session with the new session id. `ActiveSessionCubit` loads that id; it must not insert another session.
- **Resume** never inserts. Bootstrap (and notification tap) finds the existing `running` / `paused` row and pushes Active Session with that id. The Cubit hydrates; it does not call `StartSession`.

---

## Persistence

Encrypted local SQLite is the only application data store.

- **Engine:** Drift with `NativeDatabase`. Encryption uses the `sqlite3` package’s `sqlite3mc` **source hook** (`hooks.user_defines.sqlite3.source: sqlite3mc` in the app pubspec). This is the documented default. Do **not** use `sqlcipher_flutter_libs` or `encrypted_drift` as the v1 path.
- **Key:** `flutter_secure_storage` holds the database key only. Generate a high-entropy key with a CSPRNG; persist it once; **never** open the database with an empty key (`sqlite3mc` treats an empty key as no encryption — fail closed). If the key is applied via a SQL `PRAGMA`, escape it; do not concatenate untrusted or unescaped material into the statement. Prefer a hex / raw-key pragma when the plugin supports it.
- **Cipher check:** In `NativeDatabase` `setup`, **before** applying the key, verify `PRAGMA cipher` is non-empty. Do this in **all** build modes and **throw** (typed `EncryptionFailure`) if it is missing — do not rely on `assert`, which is stripped in release. If cipher is absent, do not write training data.
- **Cipher choice:** Use sqlite3mc’s modern default for a new database. Do not select RC4 or other weak ciphers. `PRAGMA cipher = 'sqlcipher'` / `legacy` modes exist only for migrating an old SQLCipher file; v1 has no such file to migrate.
- **Settings:** the SQLite `settings` table is the single source of truth (units, theme mode, rest auto-start, and later app-lock preference). Do not add `shared_preferences`.
- **Time:** persist UTC instants for event timestamps; capture the IANA zone ID at session start; use a calendar-date type for schedule days, not a `DateTime` instant. Remaining rest is `rest_target_at - now` via `lib/core/clock.dart` so tests can freeze `now`.
- **Mass:** store absolute mass as integer milligrams; kg/lb is a display setting. See [data-model.md](data-model.md).

### Backup and device-only storage

Product: data lives on this device only ([privacy-export.md](features/privacy-export.md)). Exclude **both** the SQLite file **and** the key material from cloud / OS backup. This is a confidentiality control, not only a “restore would fail” footnote.

- Android: `android:allowBackup="false"`, or backup / `dataExtractionRules` that exclude the database file **and** `flutter_secure_storage` prefs. Flutter’s default Auto Backup is on if unspecified.
- iOS: exclude the database from iCloud backup (`NSURLIsExcludedFromBackupKey` or an equivalent no-backup location). Use a **this-device** Keychain accessibility class so the key does not sync via iCloud Keychain. “Accessibility” here means Keychain data-protection flags, not VoiceOver.
- Configure `flutter_secure_storage` Android backup exclusion per plugin guidance so a restored key blob cannot be decrypted without the Keystore key — **in addition to** excluding the database file.

Migrations are versioned, transactional, and generated/tested. They run on launch **before** any session-resume query.

---

## Durability contract

Maps to [invariants.md](invariants.md) #1 (never lose a completed set) and the template-snapshot invariants (#2–#4, #6).

- **Success** for a completed set or session state change means **the Drift transaction committed**. The UI may show **in-flight** pending or error chrome until that commit. Never report a set as completed (no success checkmark, no “saved”) before commit. Retry transient writes with a bound; never drop the completed set on a temporary failure — surface retry / error instead.
- **Starting a session** (copy template → `session` + `session_exercise` + `session_set`, optional `schedule_entry` link) is **one database transaction**.
- Rest remaining or overdue time is always `rest_target_at - now` (injected `clock.dart`). Never persist a decrementing countdown integer.
- **Kill / relaunch:** after migrations complete, query for any `running` or `paused` session and push Active Session (see Navigation). The database is already open; migrations do not run on a closed database.
- Temporary write failure must not drop a completed set.

---

## Startup sequence

Required order. Do not query sessions or show the shell until migrations have finished.

1. Load or create the database key from secure storage (CSPRNG on first launch; this-device Keychain / Keystore; backup exclusion as above).
2. Open the Drift database. In `NativeDatabase` `setup`, verify `PRAGMA cipher` is non-empty (**throw** if not, all build modes), reject an empty key, then apply the key.
3. Run migrations to the current schema — **before** session-resume queries.
4. Construct services and repositories.
5. Query for an in-progress (`running` / `paused`) session. Remember its id for the router; do not construct `ActiveSessionCubit` here.
6. `runApp` with `MultiRepositoryProvider` and `go_router`. The **initial location is the four-tab shell**. If step 5 found a session, **push** Active Session onto that shell after it is mounted (redirect / extra). Do **not** set Active Session as `initialLocation` in place of the shell.

---

## Navigation

Four tabs via `go_router` `StatefulShellRoute.indexedStack`: **Today**, **Planner**, **History**, **Workouts**. Settings and Active Session are **pushed routes on top of the shell**, not a fifth tab and not a replacement for the shell. Workout builder / detail screens are pushed on the Workouts branch.

This is the same path for cold start, warm resume, and notification tap:

1. Mount the tab shell (so Finish / back has somewhere to go).
2. If a `running` / `paused` session exists, **push** Active Session with that session id.
3. Never start a second session. Never mount Active Session as the only route.

- Cubits for tab roots live with the shell branch that owns that tab.
- `ActiveSessionCubit` is created in the Active Session **route builder**, not as a process-wide singleton.
- Tab badges or “session in progress” chrome on Today read a **repository stream**. They must not read `ActiveSessionCubit` from another Cubit.

---

## Rest-timer notifications (P0)

The rest timer **must** alert when the app is backgrounded or terminated. Remaining / overdue time is always `rest_target_at - now`. The notification payload is not a clock.

In-app timer UX (non-modal, skip / ±30s / reset, auto-start setting) and OS schedule / cancel / tap / permission: [features/active-session.md](features/active-session.md). Package names and the kill-safe foreground policy are summarized **here**.

Packages: `flutter_local_notifications`, `timezone`, `flutter_timezone` (conditional — first imported with Active Session / timer work).

**Arming.** When rest starts (including auto-start), persist `rest_*` (repository transaction) **then** schedule an OS local notification for `rest_target_at` (`NotificationService`, orchestrated by `ActiveSessionCubit` or a rest-timer use case). Capture the IANA zone at session start (`flutter_timezone`) and schedule with `timezone` zoned APIs.

**Cancel / reschedule on rest-field changes.** Skip, ±30s, reset, new set complete, pause, finish, and abandon must update rest fields and cancel or reschedule that notification. Cancel the OS notification when rest is no longer armed.

**Foreground policy (kill-safe).** While rest is armed, **keep the OS notification scheduled**. While the app is in the foreground, **suppress presentation** so the user is not double-alerted (plugin foreground-presentation flags / equivalent). Do **not** cancel the scheduled notification merely because the app is foregrounded — unexpected process death from the foreground will not reliably run a “reschedule on background” callback. A terminated app relies on the already-scheduled OS notification.

**Notification tap.** Same path as startup: shell first, then push Active Session if a `running` / `paused` session exists. Never start a second session.

**Permission.** Request notification permission at the first rest that needs an alert, or from Settings. Denial degrades to the in-app timer only and **must not** fail set persistence.

**Privacy.** Title and body must not include exercise names, loads, notes, or other workout detail (lock screen, recents, Wear). Payload carries at most a stable session id. Use Android visibility / iOS preview settings appropriate for a timer alert without training data.

---

## Export delivery

JSON is the P0 portability format. The file is a **plaintext** dump of decrypted local data (user-mediated share). Write it only under the app’s private cache or temp directory. Delete it after share completes or is cancelled; best-effort delete on process death. On Android, if using `FileProvider`, keep it unexported and grant URI permission only for that share. Do not write export files to shared Downloads storage.

---

## UI library

No third-party UI / neumorphism / calendar / form-builder **kit**. The visual language in [design.md](design.md) (selective neumorphism, Nord-influenced tokens) is implemented in-repo.

Flutter **Material 3** widgets are the behavioral foundation (focus, semantics, text scaling, `NavigationBar`, buttons, fields, dialogs, snackbars). Map those tokens through `ThemeData`, `ColorScheme`, component themes, and a `ThemeExtension` (for example `VulcanColors`).

Own only recurring primitives under `lib/ui/core/widgets/` (`VulcanSurface`, metric field, set row, rest timer ring, and similar). Prefer theming a standard widget over wrapping it. Week strip and month dots are custom, using Flutter date helpers.

Do **not** add `flutter_neumorphic*`, a general calendar package, or a form-builder.

---

## Target folder structure

Future paths. Do not treat this tree as already present in the repo; architecture-docs work does not create these directories.

```
lib/
  app/           # app.dart, bootstrap.dart, router.dart, dependencies.dart
  core/          # result.dart, failure.dart, clock.dart  (no utils/widgets junk drawers)
  data/
    database/    # app_database, tables/, daos/, migrations/
    repositories/
    services/    # secure key, notifications, timezone, export
  domain/
    models/
    repositories/
    use_cases/   # only cross-repository / complex / reused workflows
  ui/
    core/theme/
    core/widgets/
    today/
    planner/
    workouts/
    active_session/
    history/
    settings/
  main.dart
```

Each `ui/<feature>/` colocates that screen, its Cubit, its state, and feature-only widgets. Repositories and the encrypted database stay central because the relational model crosses UI features.

---

## Testing contract

Documented now; tests land in later implementation PRs. Existing `test/widget_test.dart` must keep passing meanwhile.

- **Unit:** mass conversion / rounding, name normalization, derived missed status, session state machine, `Result` mapping, rest remaining time against a fake clock.
- **Drift repository tests** on a temporary real SQLite database (foreign keys, snapshot transaction).
- **Generated migration tests** for every schema version.
- **Encryption:** tests (and a debug/CI check) that `PRAGMA cipher` is present and that an empty key is rejected. Do not store fixtures that assume plaintext if the production path is encrypted.
- **`bloc_test`** with hand-written fakes (no mocking package by default).
- **Widget tests** at large text scale plus accessibility guideline checks (48dp targets, labels, contrast).
- **Integration tests** (Android and iOS, later workflow): key startup, kill / resume, app lock, export share sheet, notification permission / tap, rest-timer recovery (including process death while rest is armed in the foreground).

**CI today:** analyze, unit / widget tests, and Android debug APK. Migration tests join CI when Drift exists. Device integration is a separate workflow.

---

## Generated code

Do not hand-edit `*.freezed.dart`, `*.g.dart`, or Drift-generated files. When those dependencies exist, use one documented `build_runner` command (README / CI). This architecture-docs change does not add those packages or that command.
