# AGENTS.md

Guidance for AI coding agents working in this repository.

**Vulcan Fitness** is a Flutter strength-training app (package `vulcan`) for self-coached lifters. Feature-level architecture lives in **skills** (`.claude/skills/`), which load on demand — see the map at the bottom. This file holds only what applies to every task.

Expo / TypeScript workspace rules do **not** apply here. Use Flutter commands below.

## Development Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter test test/features/settings/settings_cubit_test.dart
```

Run `build_runner` after changing freezed models, injectable registrations, or other codegen sources. Prefer Cubits over full Blocs unless an event stream is required.

## Information Architecture

Bottom nav: **Today** (home) · **Planner** · **History** · **Workouts** (templates). **Settings** is reached from Today, not a fifth tab. Core loop: Plan → Schedule → Perform → Review.

## Repo-Wide Invariants

Product contracts — violating any is a bug:

1. A completed set is never lost because of app backgrounding, lock, process death, or a temporary write failure.
2. Training data is saved locally before any Health sync is attempted.
3. Health sync failure never blocks session completion.
4. Historical sessions do not change when a workout template changes.
5. Archived templates remain available to historical sessions.
6. Deleted templates never delete historical sessions.
7. Changing display units never changes stored historical values.
8. A session may diverge from its template without mutating that template.
9. Every Health sync operation is retryable and idempotent.
10. App operation does not require an internet connection.

**MVVM / Cubit:** `flutter_bloc` Cubits are feature ViewModels. Business rules live in use-cases / domain — not in widgets and not in repositories. Session finish enqueues Health sync; it never awaits a successful platform write.

**Mass:** Store canonical mass as integer milligrams. Render in the user's display unit (`kg` / `lb`).

## Testing

- Stack: `flutter_test`, `bloc_test`, `mocktail`.
- Pattern: `test/features/settings/settings_cubit_test.dart`, `test/data/settings_repository_test.dart`.
- Regenerate codegen before tests if freezed / injectable sources changed.
- Prefer testing Cubit behavior and repository contracts; keep widgets thin.

## External Services (v1)

- **Apple HealthKit** and **Google Health Connect** — write-only (workout + duration; HR only if measured; no estimated calories).
- No cloud backup, no account, no cross-device sync, no Stripe/OAuth.

## Where the Rest Lives

| Skill | Covers |
| --- | --- |
| `flutter-conventions` | Folders, Cubit-as-VM, injectable, freezed, fpdart, codegen |
| `local-data-and-units` | SQLite/SQLCipher, migrations, mg mass, settings keys |
| `active-session` | Snapshotting, autosave, rest timer, set logging |
| `health-sync` | HealthKit/Health Connect outbox, retry, idempotency |
| `templates-and-workouts` | Mutable templates, archive, structured load/rep |
| `planner` | Week operational / month overview, `schedule_entry` |
| `history` | Session list, per-exercise “last time” |
| `privacy-export` | Local-first, JSON export, no import in v1 |
| `ui-design-a11y` | Neumorphic/Nord tokens, Manrope, a11y |

Skill files: `.claude/skills/<name>/SKILL.md`. Deep product specs: `docs/vulcan/`. Plans/spikes: `.ai/specs/`, `.ai/spikes/`.
