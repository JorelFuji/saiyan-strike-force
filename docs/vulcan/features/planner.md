# Weekly / Monthly Planning

Scheduler for placing templates onto dates. Week view is operational; month view is overview-only.

Related: [screens.md](../screens.md), [data-model.md](../data-model.md) (`schedule_entry`).

---

## Spec

- **Week view** is the operational planner: 7-day strip, named workouts, add/move/skip.
- **Month view** is a structural overview only. Days show presence markers, not workout detail:

  ```
  Mon Tue Wed Thu Fri Sat Sun
   ●       ●       ●
      ●           ● ●
  ```

  Selecting a day reveals the workout list for that date.
- Add a workout to a date by tapping the date → "Add workout." Long-press + drag of a template onto a date is allowed as a secondary action; do not invest in elaborate drag-and-drop.
- A given date can hold multiple workouts. Each `ScheduleEntry` has:
  - `date`
  - `start_time` nullable
  - `label` nullable (enough to distinguish AM / PM / unnamed second session — not a full calendar scheduler)
- **Copy week forward** (duplicate this week's structure onto next week, then edit exceptions) is the high-value planner action. Prioritize it over sophisticated drag-and-drop. **P1 if it delays week view**, but design the model so the action is a straightforward copy of `ScheduleEntry` rows.
- Planning is entirely manual — no auto-generated periodization.

## Schedule status is mostly derived

Do not persist `"missed"` as a user-mutable database state unless there is a specific user action.

`ScheduleEntry` status:

```
planned
skipped                 # explicit user action
completed_by_session    # linked to a finished session
```

UI "missed" is derived: `date` is before today (in the device's local calendar), status is still `planned`, and no finished session is linked.

Handle these edge cases explicitly:
- A scheduled workout is started then abandoned → schedule stays `planned` (or user can skip); session status is `abandoned`.
- Two workouts on one date → two entries; optional `label` / `start_time` distinguishes them.
- A workout is rescheduled → move the entry's `date`; do not leave a ghost "missed" on the old day.
- A session is started without a schedule entry → allowed (ad hoc / freestyle); no schedule row required.
- A scheduled workout is completed after midnight → the session keeps its `started_at` timezone; the schedule entry stays on the planned date unless the user moves it.
- A template is archived after being scheduled → existing entries remain; starting them still snapshots the current template body (or last known body). History is unaffected.
