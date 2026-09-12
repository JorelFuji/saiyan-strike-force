# Workout Templates

Reusable workout definitions the user builds and edits. Templates are **mutable**; sessions snapshot them at start — see [active-session.md](active-session.md) and [invariants.md](../invariants.md).

---

## Spec

- Create/edit/duplicate/archive workout templates — no cap on count. Delete is allowed only when it cannot orphan history (sessions keep snapshots; deleting a template must not cascade-delete sessions).
- Each template: name, optional notes/tags (freeform, e.g., "Push," "Lower A"), ordered list of exercises.
- Each exercise entry (user types the name — no picker/library):
  - Exercise name (free text). Store the original display name plus a normalized lookup key (trim, collapse whitespace, case-fold) so `"Bench Press"`, `"bench press"`, and `"Bench press "` are one autocomplete result. Autocomplete is the user's own names, not a curated library.
  - Structured rep prescription (not an opaque `"6–8"` string):
    - `rep_type`: `fixed` | `range` | `amrap`
    - `target_reps` (fixed)
    - `min_reps` / `max_reps` (range)
  - Structured load (not a text+number hybrid). Render as one compact control:

    ```
    LoadType: none | bodyweight | absolute | percentage | target_rpe | text
    weight_canonical_mg   # integer milligrams when LoadType = absolute
    percentage            # when LoadType = percentage
    target_rpe            # when LoadType = target_rpe
    freeform_text         # when LoadType = text
    ```

  - Rest duration in seconds (used by the in-session rest timer)
  - Optional superset grouping — **P1**. v1 ships without supersets if it delays Active Session.
- Reordering exercises within a template via long-press drag handle.

Templates are **mutable definitions**. Sessions are **immutable-at-start snapshots** of the prescription. Editing a template after a session has started must not rewrite that session's planned values.

Canonical mass storage and unit rules: [data-model.md](../data-model.md).
