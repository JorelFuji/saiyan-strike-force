# History

Session and exercise history. The primary question is **"what did I do last time?"**, not "how did my volume trend over six months?"

Related: [active-session.md](active-session.md) (snapshots).

---

## Spec

- Reverse-chronological list of finished sessions, grouped by date. Each entry: workout name snapshot, date, duration, total volume, completion (e.g., 18/20 sets).
- Tap a session → full breakdown (every set as logged). v1 is read-only except where needed to resume an in-progress session. **Past-session number edits are P1.**
- **Exercise history is the fast path.** Select an exercise (normalized name) → every historical instance:

  ```
  BENCH PRESS

  Sep 8   225 × 5, 5, 5, 4
  Sep 4   220 × 5, 5, 5, 5
  Sep 1   215 × 5, 5, 5, 5
  Aug 28  210 × 5, 5, 5, 5
  ```

  Optional secondary stats on the same screen, not a dashboard: volume, top set, estimated 1RM, best weight. No major analytics suite in v1.
- Filter/search by workout name snapshot or date range.
