# System Invariants

These are product contracts, not implementation suggestions. Violating any of them is a bug.

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

Primary implementers: [features/active-session.md](features/active-session.md), [features/health.md](features/health.md), [data-model.md](data-model.md).
