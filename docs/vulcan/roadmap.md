# Roadmap

v1 priority, deferred work, and closed decisions.

---

## v1 Priority

Build in this order. Do not start pixel-pushing Active Session until the snapshot model, set persistence, and tap-first row exist.

### P0 — must be correct before launch
- Encrypted local DB, migrations, `app_metadata`
- Workout templates with structured load/rep
- Template → session snapshotting
- Session state machine + continuous autosave/recovery
- Active Session, tap-first set entry, excellent numeric keyboard
- Rest timer with absolute `rest_target_at`, non-modal, background-safe
- Scheduler week view
- History list + session detail
- Exercise history ("last time")
- HealthKit / Health Connect write pipeline + outbox + retry
- Dark + light themes from tokens
- Accessibility fundamentals ([accessibility.md](accessibility.md))
- Settings → Export JSON
- Freestyle sessions (nullable `workout_id` — cheap once snapshotting exists)
- Template archive flag (required by invariants 5–6)

### P1 — important, simplify or follow quickly
- Month view (dots + day sheet) if not already shipped with week view
- Copy / duplicate week
- Superset support
- Optional RPE chip on sets (schema already has `rpe`; the chip can wait)
- Past-session editing (local only; do not rewrite Health)
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

---

## Decisions (closed)

| # | Decision | Resolution |
|---|---|---|
| 1 | Template snapshot | Starting a session snapshots the prescription. Templates remain mutable. No `template_version` table in v1. |
| 2 | Load / rep model | Structured fields (`LoadType`, rep type/range/AMRAP). Compact UI, not hybrid strings. |
| 3 | Health writes | Workout + duration; HR only if measured; no estimated energy. Outbox, retryable, idempotent. |
| 4 | Backup | Export JSON in v1. No import. |
| 5 | Light theme | In v1, tokenized with dark from the start. |
| 6 | Active Session | Tap-first. No swipe-to-complete, swipe-to-delete, or double-tap edit. |
| 7 | Typography | Manrope, tabular figures. |
| 8 | State management | Cubit/`flutter_bloc` as feature ViewModels + thin use-cases. |
| 9 | Mass | Canonical integer milligrams; render in settings unit. |
| 10 | Flutter | Spec = current stable; repo + CI pin the exact SDK at init. |

> ⚠️ OPEN: None that block implementation. Plate-calculator UX and "show original logged unit on a historical set" can be decided during build without schema changes (canonical mg is enough).
