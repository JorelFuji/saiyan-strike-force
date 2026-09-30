# Local Data Model

SQLite schema, units/precision, and encryption at rest. Persistence engine, repositories, and transactions: [architecture.md](architecture.md). Session snapshot field detail: [features/active-session.md](features/active-session.md). Invariants: [invariants.md](invariants.md).

---

## Local Data Model (SQLite)

| Table | Key columns |
|---|---|
| `app_metadata` | `key`, `value` including `schema_version` / migration bookkeeping |
| `workout` | id, name, notes, created_at, archived_at nullable |
| `workout_exercise` | id, workout_id, name, normalized_name, order_index, structured rep fields, structured load fields, rest_seconds, superset_group nullable |
| `schedule_entry` | id, workout_id, date, start_time nullable, label nullable, status (`planned`/`skipped`/`completed_by_session`), session_id nullable |
| `session` | id, workout_id nullable, schedule_entry_id nullable, workout_name_snapshot, started_at, ended_at, timezone (IANA, captured at start), status, notes, rest_* timer fields |
| `session_exercise` | snapshot fields per [active-session.md](features/active-session.md) |
| `session_set` | planned + actual structured fields, rpe, completed, completed_at |
| `settings` | key, value (units, theme mode, rest auto-start, later app-lock flag) |

The `settings` table is the **only settings store** (units, theme mode, rest auto-start, and later the app-lock preference). Do not add `shared_preferences`. `flutter_secure_storage` holds the database encryption key only, not user settings.

No separate `exercise_name_history` table in v1. Autocomplete = distinct `normalized_name` from `workout_exercise` ∪ `session_exercise`, display = most recently used original `name`. Add a dedicated index table later if the dataset needs it.

Migrations are versioned and must run on launch before any session resume.

## Units and precision

`weight + unit` is not enough.

**Store canonical mass as integer milligrams.** Render in the user's selected unit. Switching kg ↔ lb never rewrites stored values (invariant 5).

Decisions for v1:

| Topic | Rule |
|---|---|
| Display unit | One app-wide setting: `kg` or `lb`. Default from locale if obvious, else kg. |
| Canonical storage | Integer milligrams for `LoadType.absolute` |
| Historical display | Convert from canonical into the **current** display unit. Stored milligrams do not change. |
| Mixed absolute units in one workout | No. Absolute loads are entered in the current display unit and stored as mg. Other `LoadType`s (bodyweight, %, RPE, text) may coexist with absolute in the same session because they are different kinds of data. |
| Bodyweight | `LoadType.bodyweight`; no mass field required. Optional later: added load as absolute on top of bodyweight — **out of v1**. |
| kg increments | Stepper default **2.5 kg**; fine entry allows **0.5 kg** |
| lb increments | Stepper default **5 lb**; fine entry allows **1 lb** |
| Decimal precision (display) | kg: 1 decimal if needed, else integer; lb: 1 decimal if needed, else integer |
| Rounding on unit switch | Convert mg → display unit, then round half-away-from-zero to the fine increment of the **target** unit (0.5 kg or 1 lb). Document the helper; use it everywhere. |
| Volume | Sum of canonical mass × actual reps for absolute-load completed sets; bodyweight/%/RPE/text sets are excluded from mass-volume or shown separately |

## Encryption at rest

Encrypted local SQLite is the only application data store. Key handling, cipher checks, backup exclusion, and repository transaction rules: [architecture.md](architecture.md) Persistence.

- **Engine:** Drift with `NativeDatabase` (or equivalent native executor). Encryption uses the `sqlite3` package’s `sqlite3mc` **source hook** (`hooks.user_defines.sqlite3.source: sqlite3mc` in the app pubspec). This is the documented default. Do **not** use `sqlcipher_flutter_libs` or `encrypted_drift` as the v1 path. Do not pin package versions here; constraints live in `pubspec.yaml`.
- **Key:** `flutter_secure_storage` holds the database key only (iOS Keychain / Android Keystore). Generate a high-entropy key with a CSPRNG; persist it once; **never** open the database with an empty key (`sqlite3mc` treats an empty key as no encryption — fail closed). Exclude **both** the SQLite file **and** the key blob from cloud / OS backup (Android Auto Backup / `dataExtractionRules`; iOS no-backup location and this-device Keychain). Configure `flutter_secure_storage` Android backup exclusion per plugin guidance.
- **Cipher check:** In `NativeDatabase` `setup`, **before** applying the key, verify `PRAGMA cipher` is non-empty. Do this in **all** build modes and **throw** (typed `EncryptionFailure`) if it is missing — do not rely on `assert`, which is stripped in release. If cipher is absent, do not write training data.
- **Cipher choice:** Use sqlite3mc’s modern default for a new database. Do not select RC4 or other weak ciphers. `PRAGMA cipher = 'sqlcipher'` / `legacy` modes exist only for migrating an old SQLCipher file; v1 has no such file to migrate.
- Optional app-lock (biometric/PIN via `local_auth`) as a Settings toggle — in v1. That preference lives in the SQLite `settings` table, not in `flutter_secure_storage` or `shared_preferences`.
