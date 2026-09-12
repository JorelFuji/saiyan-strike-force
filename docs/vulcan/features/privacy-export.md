# Data & Privacy

Local-first data contract and backup via export.

Related: [data-model.md](../data-model.md) (encryption), [roadmap.md](../roadmap.md) (export is P0).

---

## Spec

- All data is local-first, encrypted at rest. No account, no login, no server. No cross-device sync in v1. Settings must state: "Your data lives on this device only."
- **Settings → Export Data is in v1.** JSON is the canonical machine-readable format. CSV of workout history is optional if inexpensive. Import is out of scope. Export is part of the local-first contract, not a convenience feature.

Encryption details: [data-model.md](../data-model.md).
