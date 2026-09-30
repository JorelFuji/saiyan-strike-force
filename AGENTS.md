# Engineering Guide

## Mission

Vulcan Fitness is an offline-first iOS and Android strength-training app for
self-coached lifters. Make the smallest safe change that solves the requested
problem. Preserve public behavior and the product contracts in
`docs/vulcan/invariants.md` unless the task explicitly changes them.

The core product loop is **plan → schedule → perform → review**. Keep features
focused on that loop: users create their own templates, plan them manually,
log sessions quickly, and review their own history. v1 has no account, cloud
sync, network requirement, exercise library, AI coaching, social features,
nutrition tracking, or HealthKit / Health Connect.

## Start Here

- Read `docs/vulcan/invariants.md` and `docs/vulcan/architecture.md` before
  changing application code. Architecture is the stack source of truth.
- Read the relevant `docs/vulcan/features/*.md` for feature work, and
  `docs/vulcan/data-model.md` before changing persisted models, storage, or
  units.
- Use `docs/vulcan/roadmap.md` to distinguish P0 scope from deferred work.
- Epic files are planning artifacts. Check the current implementation, tests,
  and git history before relying on an epic's `status` field.

## Toolchain and Commands

Flutter is pinned to **3.47.4 stable** and Dart to **3.13.3**. Use FVM; do not
silently use a system Flutter/Dart version.

- Install: `fvm install && fvm use 3.47.4 && fvm flutter pub get`
- Verify SDK pin: `./tool/verify_flutter_pin.sh`
- Develop: `fvm flutter run`
- Format: `fvm dart format lib test`
- Analyze / lint: `fvm flutter analyze --fatal-infos`
- Test all: `fvm flutter test`
- Test one: `fvm flutter test test/path/to_test.dart`
- Android build: `fvm flutter build apk --debug`

When Freezed or Drift land, generate with `fvm dart run build_runner build`
and do not hand-edit `*.freezed.dart`, `*.g.dart`, or Drift-generated files.
Do not add a codegen-verify script until one is committed in `tool/`.

Run the SDK-pin check, formatting, analyzer, and relevant tests before
declaring work complete. If a command cannot run, state exactly why and what
remains unverified.

## Architecture

This project uses MVVM. Screen and workflow Cubits are ViewModels; use
`flutter_bloc` when the `ui/` layer is introduced. Prefer Cubits over full
Blocs unless an event stream genuinely needs event handling.

```
View → Cubit (one screen or one workflow)
  → Use case (only StartSession / FinishSession / ResumeSession
     and similar cross-repository workflows)
  → Repository interfaces
    → Drift database
    → Platform services
```

- `lib/app/`: composition root (`bootstrap.dart`, `dependencies.dart`),
  `go_router`, `MultiRepositoryProvider`.
- `lib/core/`: in-repo `Result` / `Failure` and `clock.dart` only — no
  widgets, theme, or service-locator junk drawer.
- `lib/data/`: Drift database, DAOs, migrations, repository implementations,
  and platform services (secure key, notifications, timezone, export).
- `lib/domain/`: models, repository contracts, and thin use-cases for real
  cross-repository workflows.
- `lib/ui/`: one folder per screen/feature (`today`, `planner`, `workouts`,
  `active_session`, `history`, `settings`) plus `ui/core` for owned Material 3
  primitives. UI and its Cubit live together.
- `test/`: mirrors production seams; unit-test domain rules and repository
  behavior, and add widget tests for UI behavior.
- `docs/vulcan/`: product and technical source of truth.

Those `lib/` directories are created by later PRs. Do not invent a parallel
layout (`lib/features`, DI in `core/`, CSV next to storage).

Simple CRUD: the Cubit calls one repository; do not add a pass-through use
case. A Cubit may depend on repositories and platform services (and on use
cases when the workflow spans them). Rest-timer “commit `rest_*` then
schedule the OS notification” belongs in `ActiveSessionCubit` or a small
rest-timer use case, not in the Drift database layer.

Keep business rules in domain/use-cases or repositories per
`docs/vulcan/architecture.md`: repositories own persistence and transaction
boundaries, return `Result` / `Future<Result<T>>`, and never leak database or
platform exceptions upward. Widgets and Cubits receive dependencies through
constructors or `context.read` of providers created above them. They do not
look up `getIt` or any other service locator.

Do **not** add `injectable`, `get_it`, `fpdart`, `shared_preferences`, or a
`csv` package in v1. Do not leave deprecated aliases (`get_it` wrappers,
`fpdart` re-exports, `shared_preferences` “just in case”).

Use Freezed **selectively** (equality / `copyWith` where it helps), not on
every type. Cubits are screen- or workflow-sized, not one Cubit per tab
forever and not per leaf widget. Apply SOLID pragmatically: one clear
responsibility per class, depend on repository abstractions at layer
boundaries, and do not introduce indirection that obscures a small feature.
Prefer existing patterns over new abstractions or dependencies.

## Data, Privacy, and Product Contracts

The seven invariants in `docs/vulcan/invariants.md` are non-negotiable:

1. A completed set is never lost because of app backgrounding, lock, process
   death, or a temporary write failure.
2. Historical sessions do not change when a workout template changes.
3. Archived templates remain available to historical sessions.
4. Deleted templates never delete historical sessions.
5. Changing display units never changes stored historical values.
6. A session may diverge from its template without mutating that template.
7. App operation does not require an internet connection.

HealthKit / Health Connect is **not** a v1 invariant. It is deferred
(roadmap Decision 3). Do not add a Health outbox, calorie estimates, or
Health packages.

Data rules:

- Persist completed-set/session changes locally **before** reporting success.
  Success means the Drift transaction committed. Recover running or paused
  sessions after backgrounding, lock, or process death (migrations first,
  then resume query).
- Snapshot a template when a session starts — **one transaction**. Template
  edits, archive, or deletion must never rewrite or remove historical
  sessions; sessions may diverge without mutating their template.
- Store absolute mass only as integer milligrams. kg/lb is a display
  setting in the SQLite `settings` table; changing units must never rewrite
  stored training values. Do not add `shared_preferences`.
- Use an absolute `rest_target_at`, never a decrementing persisted countdown.
  Remaining time is `rest_target_at - now` via `lib/core/clock.dart`.
  Rest-timer OS notifications (`flutter_local_notifications`) are P0 so the
  timer still alerts when the app is backgrounded or terminated; they are
  not a new product invariant. Permission denial degrades to the in-app
  timer only and must not fail set persistence.
- Keep data local and encrypted at rest (Drift + native SQLite + `sqlite3mc`
  source hook). Do not use `sqlcipher_flutter_libs` or `encrypted_drift` as
  the v1 path. Do not add runtime network dependencies, accounts, server
  sync, or imports in v1. Export JSON via `dart:convert` and a share sheet
  (`share_plus`) is the v1 data-portability path.

## UI

Implement dark and light design tokens together via Material 3 `ThemeData`,
`ColorScheme`, and a `ThemeExtension`. Preserve accessible contrast and
visible focus/active boundaries, support OS text scaling, use 48×48dp
minimum targets, and provide semantics for icon-only controls.

Active Session is tap-first: do not add swipe-to-complete, swipe-to-delete,
or double-tap editing. Destructive actions require an explicit control plus
Undo or confirmation.

No third-party UI / neumorphism / calendar / form-builder kit. Own recurring
primitives under `lib/ui/core/widgets/`.

## Implementation Rules

- Read nearby code and tests before editing; make focused diffs and avoid
  drive-by formatting or refactors.
- Reuse documented primitives (integer milligrams, calendar date vs UTC
  instant, IANA zone at session start, `Result` / `Failure`). A planner date
  or start time is a local calendar reading, not an instant; do not model
  either as a `DateTime`.
- Persisted enums carry an explicit `wireValue` string and a `fromWire`
  returning `Result`; never persist `Enum.index` or `Enum.name`.
- Validate untrusted wire data independently of `@Assert`, which is stripped
  from release builds. `@Assert` catches programmer errors; a `fromWire` or
  `validate()` returning `Result` is what guards stored data.
- Keep SQL shapes, SQL types, and platform APIs in `data/`; map them
  explicitly at the boundary rather than exposing them in domain contracts.
- Treat unknown or corrupt persisted values as typed `Failure`s, not crashes
  or silent defaults, unless the specification defines a default.
- Do not edit generated `*.freezed.dart`, `*.g.dart`, or Drift-generated
  files by hand. Regenerate and commit their changes with their source edits.
- Do not change lockfiles, schemas, migrations, SDK pins, or public
  interfaces unless the task requires it. Migrations must be ordered,
  transactional, and run before session-resume checks.
- Never add secrets, credentials, production data, or `.env` contents to
  code, logs, tests, or commits.

## Testing and Delivery

- Add or update tests for behavior changes and bug fixes, covering primary,
  failure, and relevant boundary paths.
- Keep tests deterministic and local; mock platform systems at their
  boundary. Tests must not require internet access. Prefer hand-written
  fakes over a mocking package.
- Do not weaken, skip, or delete tests to make the suite pass.
- Before finishing, summarize behavior changes, checks run and outcomes, and
  any risks, migrations, follow-ups, or unverified work.

## Git and Review

- Keep commits small and single-purpose.
- Do not amend, force-push, reset, or discard user changes without explicit
  approval.
- Flag security, encryption, backward-compatibility, accessibility,
  performance, and data-migration risks for review.
