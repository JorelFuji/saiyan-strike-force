# Roadmap

v1 priority, deferred work, and closed decisions.

---

## v1 Priority

Build in this order. Do not start pixel-pushing Active Session until the snapshot model, set persistence, and tap-first row exist.

### P0 — must be correct before launch
- Encrypted local DB via Drift + tested migrations, `app_metadata`
- Workout templates with structured load/rep
- Template → session snapshotting
- Session state machine + continuous autosave/recovery
- Active Session, tap-first set entry, excellent numeric keyboard
- Rest timer with absolute `rest_target_at`, non-modal, background-safe, and OS notification when backgrounded or terminated
- Scheduler week view
- History list + session detail
- Exercise history ("last time")
- Dark + light themes from tokens via Material 3 + `ThemeExtension`; no third-party UI kit
- Accessibility fundamentals ([accessibility.md](accessibility.md))
- Settings → Export JSON
- Freestyle sessions (nullable `workout_id` — cheap once snapshotting exists)
- Template archive flag (required by invariants 3–4)

### P1 — important, simplify or follow quickly
- Month view (dots + day sheet) if not already shipped with week view
- Copy / duplicate week
- Superset support
- Optional RPE chip on sets (schema already has `rpe`; the chip can wait)
- Past-session editing (local only)
- Schedule labels / start_time polish

### P2 — defer
- Accent customization
- Complex gestures (swipe-to-complete, card-swipe navigation, double-tap edit)
- Sophisticated analytics / multiple charts
- Import
- Cloud sync
- Wearables
- AI / social / curated exercise library
- Estimated calories
- Added-load-on-bodyweight

---

## What's deliberately deferred (post-v1)

- Cloud backup / cross-device sync
- Import
- Exercise library beyond the user's own normalized names
- AI-generated programming
- Social features
- Nutrition tracking
- Accent customization
- Analytics dashboard
- Template version history as a first-class user feature (sessions already snapshot)
- Apple HealthKit / Google Health Connect write-only workout + duration; no estimated calories; outbox/retry TBD when revived
- Update template from finished session

---

## Decisions (closed)

| # | Decision | Resolution |
|---|---|---|
| 1 | Template snapshot | Starting a session snapshots the prescription. Templates remain mutable. No `template_version` table in v1. |
| 2 | Load / rep model | Structured fields (`LoadType`, rep type/range/AMRAP). Compact UI, not hybrid strings. |
| 3 | Health integration | No HealthKit / Health Connect in v1. Deferred post-v1. |
| 4 | Backup | Export JSON in v1. No import. |
| 5 | Light theme | In v1, tokenized with dark from the start. |
| 6 | Active Session | Tap-first. No swipe-to-complete, swipe-to-delete, or double-tap edit. |
| 7 | Typography | Manrope, tabular figures. |
| 8 | State management | Cubit/`flutter_bloc` as screen/workflow ViewModels + thin use-cases. |
| 9 | Mass | Canonical integer milligrams; render in settings unit. |
| 10 | Flutter | Spec = current stable; repo + CI pin the exact SDK at init. |
| 11 | Persistence engine | Drift + native SQLite + sqlite3mc encryption; not an unspecified SQLCipher plugin as the default. |
| 12 | Settings store | SQLite `settings` only. No `shared_preferences` in v1. Secure storage is the DB key (and OS secrets), not user settings. |
| 13 | DI | Explicit constructors + `RepositoryProvider`/`BlocProvider`. No `injectable`/`get_it` in v1. |
| 14 | Errors | In-repo `Result`/`Failure`. No `fpdart` in v1. |
| 15 | UI components | Material 3 + owned `ui/core`. No third-party UI/neumorphism/calendar/form kit in v1. |
| 16 | Rest alerts | Local notifications when backgrounded/terminated are P0. |
| 17 | Export delivery | JSON via `dart:convert` + share sheet (`share_plus`). `csv` package deferred with optional CSV. |
| 18 | Freezed | Selective, not required on every type. |
| 19 | Cubit granularity | Screen/workflow Cubits, not one Cubit per tab-feature forever and not per leaf widget. |
| 20 | Template sets | Per-set reps, load, and rest in a `workout_set` child table (schema v2). Exercise-level columns are derived on write. No set types in v1. |

> ⚠️ OPEN: None that block implementation. Plate-calculator UX and "show original logged unit on a historical set" can be decided during build without schema changes (canonical mg is enough).
