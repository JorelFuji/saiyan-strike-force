# System Invariants

These are product contracts, not implementation suggestions. Violating any of them is a bug.

1. A completed set is never lost because of app backgrounding, lock, process death, or a temporary write failure.
2. Historical sessions do not change when a workout template changes.
3. Archived templates remain available to historical sessions.
4. Deleted templates never delete historical sessions.
5. Changing display units never changes stored historical values.
6. A session may diverge from its template without mutating that template.
7. App operation does not require an internet connection.

Primary implementers: [features/active-session.md](features/active-session.md), [data-model.md](data-model.md).
