# Data & Privacy

Local-first data contract and backup via export.

Related: [data-model.md](../data-model.md) (encryption), [architecture.md](../architecture.md) (export delivery), [roadmap.md](../roadmap.md) (export is P0).

---

## Spec

- All data is local-first, encrypted at rest. No account, no login, no server. No cross-device sync in v1. v1 does not write to Apple Health or Health Connect. Settings must state: "Your data lives on this device only."
- **Settings → Export Data is in v1.** JSON is the canonical machine-readable format. The file is a **versioned envelope** (`schemaVersion`, `exportedAt`, `appVersion`, collections). Import is out of scope. Export is part of the local-first contract, not a convenience feature.
- **Delivery:** write a private temp JSON file under the app cache or temp directory and invoke the platform share sheet (`share_plus`). Do not depend on `file_selector` save-dialog on mobile. Do not write export files to shared Downloads storage. Delete the temp file after share completes or is cancelled; best-effort delete on process death. On Android, if using `FileProvider`, keep it unexported and grant URI permission only for that share.
- CSV of workout history is optional / P2-adjacent. **Do not add a `csv` package until that work is scheduled.** JSON uses `dart:convert` (optional `json_serializable` for the envelope DTO).
- Export reads SQLite, including the `settings` table. There is no second preferences store. Do not add `shared_preferences`.

Encryption details: [data-model.md](../data-model.md).
