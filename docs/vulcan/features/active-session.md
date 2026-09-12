# Active Session

Starting and running a workout — the highest-frequency product surface. Accidental input is worse than one extra tap.

Contracts: [invariants.md](../invariants.md). Schema detail: [data-model.md](../data-model.md). Gestures: [design.md](../design.md). Health enqueue on finish: [health.md](health.md).

---

## Start paths

- Scheduled workout from Today or Planner
- Any template ad hoc
- Fully blank/freestyle session (`workout_id` null)

## Session state machine

```
draft → running → paused → running
              ↘ finished
              ↘ abandoned
```

| State | Meaning |
|---|---|
| `draft` | Created, not yet logging (rare; used if pre-created from a schedule tap that was cancelled) |
| `running` | Active logging; rest timer may be armed |
| `paused` | Explicit pause or OS background with session still recoverable as in-progress |
| `finished` | User completed the session; immutable except for explicit past-session edits (P1) |
| `abandoned` | User discarded an in-progress session; logged sets that were completed remain in the DB unless the user confirms discard |

A session autosaves continuously (after every completed set, every field edit, every state change) and must be recoverable after:
- app termination
- OS suspension
- phone lock
- notification interaction
- process death
- temporary database/write failure

On launch, if a `running` or `paused` session exists, resume it.

## Template → session snapshot

Starting a session **copies** the prescription. The live template is not the historical record.

```
session
  id
  workout_id                nullable
  schedule_entry_id         nullable
  workout_name_snapshot
  started_at
  ended_at                  nullable
  timezone                  # IANA, captured at start
  status
  notes
  rest_started_at           nullable
  rest_duration_seconds     nullable
  rest_target_at            nullable

session_exercise
  id
  session_id
  name_snapshot
  normalized_name
  order_index
  planned_sets
  planned_rep_type / planned_target_reps / planned_min_reps / planned_max_reps
  planned_load_type + corresponding planned load fields
  planned_rest_seconds
  superset_group            nullable, P1

session_set
  id
  session_exercise_id
  set_index
  planned load/rep fields (copied at start / when the set is added)
  actual load/rep fields
  rpe                       nullable
  completed
  completed_at              nullable
```

Do not introduce a general-purpose `template_version` table in v1. The session snapshot *is* the version. A session may add/remove sets and exercises without mutating the template (invariant 8).

## Active Session interaction (tap-first)

Do **not** ship: swipe-right to complete, swipe-left to delete, double-tap to edit, or horizontal exercise-card swipe as the primary navigation. Horizontal gestures are already used by OS back and by week paging; nesting them on the logging surface causes accidental input.

**Primary:** tap a value to edit → tap the set-complete control.
**Secondary:** direct numeric keyboard entry (this should be excellent — faster than steppers for experienced lifters).
**Secondary navigation:** compact exercise strip/list (current exercise, N / M sets).
**Destructive:** overflow/menu or explicit "Remove set" — not swipe.

Canonical active-set row:

```
Bench Press                         3 / 5

Set 1   225 lb   5   ✓
Set 2   225 lb   5   ✓
Set 3   225 lb   4   ○   ← obvious active treatment
Set 4   225 lb   5   ○
Set 5   225 lb   5   ○

        + Add Set
```

The current set has an obvious active treatment. Completing a set is an explicit control, not a gesture to discover.

Steppers may exist as a secondary increment control using the unit's configured increment. They are not the primary input path.

Also:
- Add an extra set on the fly, or remove one via menu.
- Add an exercise on the fly (session diverges from template; template unchanged).
- Live elapsed session timer from `started_at`.
- Finish → Session Summary (total volume, duration, sets/reps completed vs. planned, Health sync state) → local save is already done; Health enqueue is best-effort.

## Rest timer

Do not implement the timer as "count down a variable every second."

Persist an absolute target:

```
rest_started_at
rest_duration_seconds
rest_target_at          # started_at + duration
```

Remaining time = `rest_target_at - now`. This recovers correctly after lock, backgrounding, suspension, and notification handling.

The timer is **not modal**. The user can keep logging while it runs.

Controls:
- Auto-start after a completed set (Settings toggle; default on)
- Skip
- +30 sec / −30 sec
- Reset
