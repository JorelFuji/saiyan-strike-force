# Issue Tracker

`ISSUES.md` is the canonical status source for bounded implementation work.
The [roadmap](docs/vulcan/roadmap.md) remains the product-priority source of
truth; local `.ai/specs/` files hold implementation detail and validation
plans. This tracker links to committed product and technical sources instead
of copying their requirements.

## Workflow

Use stable, never-reused `VF-###` IDs. Renaming an outcome does not change its
ID. Issue types are `feature`, `bug`, `chore`, and `spike`; priorities follow
the roadmap's `P0`, `P1`, and `P2` classifications.

Allowed statuses are:

- `proposed` — documented work that is not yet unblocked and ready to begin.
- `ready` — requirements are sufficiently clear and every dependency is done.
- `in-progress` — a contributor is actively working on it.
- `blocked` — progress requires a named dependency or decision; record it in
  `Depends on` or the issue's references.
- `done` — implementation and relevant validation are complete, with delivery
  evidence linked in `References`.

Keep at most one `in-progress` issue per active contributor unless an explicit
exception is recorded here. The `Ready next` queue contains only ready issues
with no incomplete dependencies and follows roadmap priority and dependency
order. Recheck it whenever a dependency completes or roadmap priority changes.
Update a row in the same change that changes work status. Keep completed rows
and their IDs and delivery references in the table; if it becomes difficult to
scan, move them into an archive section without renumbering or removing them.

## Ready next

No outcomes are ready to begin.

## Issues

| ID | Outcome | Type | Priority | Status | Depends on | References |
| --- | --- | --- | --- | --- | --- | --- |
| VF-001 | Establish the version-1 schema and transactional migrations | feature | P0 | done | — | [schema commit](https://github.com/jesusxambro/vulcan-fitness/commit/56fecba), [integrity fix](https://github.com/jesusxambro/vulcan-fitness/commit/b052046), [migration tests](test/data/database/app_database_test.dart), [constraint tests](test/data/database/schema_constraints_test.dart) |
| VF-002 | Open encrypted storage with device-bound keys and fail-closed startup | feature | P0 | done | VF-001 | [delivery commit](https://github.com/jesusxambro/vulcan-fitness/commit/dedee32), [encryption tests](test/data/database/encrypted_database_factory_test.dart), [key tests](test/data/services/secure_key_service_test.dart), [bootstrap tests](test/app/bootstrap_test.dart), [backup tests](test/data/services/android_backup_rules_test.dart), [iOS backup test](ios/RunnerTests/RunnerTests.swift) |
| VF-003 | Persist mutable workout templates with structured prescriptions and canonical loads | feature | P0 | done | VF-002 | [template requirements](docs/vulcan/features/templates.md), [data model](docs/vulcan/data-model.md), [architecture](docs/vulcan/architecture.md), [roadmap](docs/vulcan/roadmap.md), [domain tests](test/domain/models), [repository tests](test/data/repositories/drift_workout_repository_test.dart) |
| VF-004 | Snapshot a template into a session in one transaction | feature | P0 | done | VF-003 | [start-session workflow](lib/domain/usecases/start_session.dart), [atomic repository](lib/data/repositories/drift_session_repository.dart), [snapshot tests](test/data/repositories/drift_session_repository_test.dart), [implementation spec](.ai/specs/2026-09-26-vf-004-template-session-snapshot.md) |
| VF-005 | Persist session state and recover every committed set | feature | P0 | done | VF-003, VF-004 | [active-session requirements](docs/vulcan/features/active-session.md), [invariants](docs/vulcan/invariants.md), [architecture](docs/vulcan/architecture.md), [delivery commit](https://github.com/jesusxambro/vulcan-fitness/commit/3ddcc3a), [resume use case](lib/domain/usecases/resume_session.dart), [finish use case](lib/domain/usecases/finish_session.dart), [session repository](lib/data/repositories/drift_session_repository.dart), [bootstrap recovery](lib/app/bootstrap.dart), [repository tests](test/data/repositories/drift_session_repository_test.dart), [bootstrap tests](test/app/bootstrap_test.dart), [part 1 spec](.ai/specs/2026-09-26-vf-005-session-state-persistence-recovery-part-1-domain-contracts.md), [part 2 spec](.ai/specs/2026-09-26-vf-005-session-state-persistence-recovery-part-2-transactional-persistence.md), [part 3 spec](.ai/specs/2026-09-26-vf-005-session-state-persistence-recovery-part-3-recovery-integration-evidence.md) |
| VF-006 | Enter and complete sets with tap-first Active Session controls | feature | P0 | done | VF-005 | [active-session requirements](docs/vulcan/features/active-session.md), [roadmap](docs/vulcan/roadmap.md), [part 3 spec](.ai/specs/2026-09-26-vf-006-tap-first-active-session-part-3-tap-first-ui-integration.md), [part 1 commit](https://github.com/jesusxambro/vulcan-fitness/commit/6ca6e67), [part 2 commit](https://github.com/jesusxambro/vulcan-fitness/commit/2623539), [part 3 commit](https://github.com/jesusxambro/vulcan-fitness/commit/fcafd08), [current-set fix](https://github.com/jesusxambro/vulcan-fitness/commit/b130e34), [ActiveSessionPage](lib/ui/active_session/active_session_page.dart), [ActiveSetRow](lib/ui/active_session/widgets/active_set_row.dart), [SetValueEditor](lib/ui/active_session/widgets/set_value_editor.dart), [ActiveSessionCubit](lib/ui/active_session/active_session_cubit.dart), [router](lib/app/router.dart), [page tests](test/ui/active_session/active_session_page_test.dart), [cubit tests](test/ui/active_session/active_session_cubit_test.dart), [router tests](test/app/router_test.dart) |
| VF-007 | Keep the absolute rest timer reliable with local notifications | feature | P0 | done | VF-006 | [delivery commit](https://github.com/jesusxambro/vulcan-fitness/commit/54595ec), [implementation spec](.ai/specs/2026-09-26-vf-007-rest-timer-local-notifications.md), [notification service tests](test/data/services/flutter_local_notification_service_test.dart), [Cubit tests](test/ui/active_session/active_session_cubit_test.dart), [UI tests](test/ui/active_session/rest_timer_controls_test.dart) |
| VF-008 | Plan workouts in a weekly scheduler | feature | P0 | done | VF-003, VF-005, VF-007 | [delivery commit](https://github.com/jesusxambro/vulcan-fitness/commit/8323f93), [implementation spec](.ai/specs/2026-09-26-vf-008-weekly-scheduler.md), [planner requirements](docs/vulcan/features/planner.md), [ScheduleRepository](lib/domain/repositories/schedule_repository.dart), [DriftScheduleRepository](lib/data/repositories/drift_schedule_repository.dart), [PlannerCubit](lib/ui/planner/planner_cubit.dart), [PlannerPage](lib/ui/planner/planner_page.dart), [repository tests](test/data/repositories/drift_schedule_repository_test.dart), [cubit tests](test/ui/planner/planner_cubit_test.dart), [page tests](test/ui/planner/planner_page_test.dart) |
| VF-009 | Review completed sessions and their set details | feature | P0 | done | VF-005 | [delivery commit](https://github.com/jesusxambro/vulcan-fitness/commit/bbeef7b), [implementation spec](.ai/specs/2026-09-26-vf-009-completed-session-history.md), [spike](.ai/spikes/2026-09-26-vf-009-completed-session-history.md), [history requirements](docs/vulcan/features/history.md), [CompletedSessionSummary](lib/domain/models/completed_session_summary.dart), [SessionRepository](lib/domain/repositories/session_repository.dart), [DriftSessionRepository](lib/data/repositories/drift_session_repository.dart), [HistoryListCubit](lib/ui/history/history_list_cubit.dart), [SessionDetailCubit](lib/ui/history/session_detail_cubit.dart), [HistoryPage](lib/ui/history/history_page.dart), [SessionDetailPage](lib/ui/history/session_detail_page.dart), [summary tests](test/domain/models/completed_session_summary_test.dart), [repository tests](test/data/repositories/drift_session_repository_test.dart), [list cubit tests](test/ui/history/history_list_cubit_test.dart), [detail cubit tests](test/ui/history/session_detail_cubit_test.dart), [page tests](test/ui/history/history_page_test.dart), [detail page tests](test/ui/history/session_detail_page_test.dart), [router tests](test/app/router_test.dart) |
| VF-010 | Find prior performance by normalized exercise name | feature | P0 | done | VF-009 | [delivery commit](https://github.com/jesusxambro/vulcan-fitness/commit/8b88cfe), [implementation spec](.ai/specs/2026-09-26-vf-010-exercise-history.md), [history requirements](docs/vulcan/features/history.md), [ExerciseHistoryEntry](lib/domain/models/exercise_history.dart), [ExerciseName](lib/domain/models/exercise_name.dart), [SessionRepository](lib/domain/repositories/session_repository.dart), [DriftSessionRepository](lib/data/repositories/drift_session_repository.dart), [ExerciseHistoryCubit](lib/ui/history/exercise_history_cubit.dart), [ExerciseHistoryPage](lib/ui/history/exercise_history_page.dart), [SessionDetailPage](lib/ui/history/session_detail_page.dart), [router](lib/app/router.dart), [domain tests](test/domain/models/exercise_history_test.dart), [repository tests](test/data/repositories/drift_session_repository_test.dart), [cubit tests](test/ui/history/exercise_history_cubit_test.dart), [page tests](test/ui/history/exercise_history_page_test.dart), [detail page tests](test/ui/history/session_detail_page_test.dart), [router tests](test/app/router_test.dart) |
| VF-011 | Provide tokenized light and dark themes with accessibility fundamentals | feature | P0 | done | VF-006 | [delivery commit](https://github.com/jesusxambro/vulcan-fitness/commit/ecf0ed3), [design](docs/vulcan/design.md), [accessibility](docs/vulcan/accessibility.md), [architecture](docs/vulcan/architecture.md), [roadmap](docs/vulcan/roadmap.md), [Settings tests](test/ui/settings), [router tests](test/app/router_test.dart) |
| VF-012 | Export local training data as versioned JSON from Settings | feature | P0 | done | VF-005, VF-009 | [delivery commit a6e890d](https://github.com/jesusxambro/vulcan-fitness/commit/a6e890d), [implementation spec](.ai/specs/2026-09-26-vf-012-versioned-json-export.md), [export workflow](lib/domain/usecases/export_data.dart), [snapshot repository](lib/data/repositories/drift_export_snapshot_repository.dart), [share service](lib/data/services/share_plus_export_share_service.dart), [domain tests](test/domain/models/export_document_test.dart), [repository tests](test/data/repositories/drift_export_snapshot_repository_test.dart), [delivery tests](test/data/services/share_plus_export_share_service_test.dart), [Settings tests](test/ui/settings/settings_cubit_test.dart) |
| VF-013 | Start and complete freestyle sessions without a template (explicit exercise/set removal is excluded; completion never deletes a set) | feature | P0 | done | VF-005, VF-006 | [spike](.ai/spikes/2026-09-29-vf-013-freestyle-sessions.md), [implementation spec](.ai/specs/2026-09-29-vf-013-freestyle-sessions.md), [start workflow](lib/domain/usecases/start_session.dart), [transactional repository](lib/data/repositories/drift_session_repository.dart), [Today](lib/ui/today/today_page.dart), [Active Session](lib/ui/active_session/active_session_page.dart), [tests](test/data/repositories/drift_session_repository_test.dart) |
| VF-014 | Reversible workout-template archive management (builder/detail/create/edit/duplicate/direct-start/permanent deletion excluded) | feature | P0 | done | VF-015 | [delivery tests](test/ui/workouts/workouts_page_test.dart), [repository tests](test/data/repositories/drift_workout_repository_test.dart), [archive UI](lib/ui/workouts/workouts_page.dart). Manual Android/iOS, screen-reader, focus, and device checks remain unavailable in this environment. |
| VF-015 | Create and edit workout templates through an accessible builder | feature | P0 | done | VF-003, VF-011 | [implementation plan](.ai/specs/2026-09-30-vf-015-accessible-workout-template-builder.md), [suggestion repository](lib/data/repositories/drift_exercise_name_repository.dart), [route-owned builder](lib/ui/workouts/workout_builder_cubit.dart), [builder page](lib/ui/workouts/workout_builder_page.dart), [shared load formatter](lib/ui/core/formatters/load_formatter.dart), [repository tests](test/data/repositories/drift_exercise_name_repository_test.dart), [builder tests](test/ui/workouts/workout_builder_page_test.dart), [router tests](test/app/router_test.dart) |

## Delivery evidence

`VF-001` and `VF-002` acceptance behavior is present in the linked
implementation and tests. For the `VF-002` handoff, SDK-pin verification,
format check, analyzer, full Flutter test suite (39 tests), and Android debug
build passed on 2026-09-25. Its iOS backup XCTest is linked above but was not
run because this environment has no `xcrun` or iOS simulator.

`VF-003` delivery evidence: the template requirements, pure domain tests, and
real-SQLite repository tests are linked in the issue row. On 2026-09-25,
SDK-pin verification, formatting, analyzer, focused tests, and the full
Flutter test suite (51 tests) passed.

`VF-004` delivery evidence: its start command, atomic Drift repository, and
real-SQLite snapshot tests are linked in the issue row. On 2026-09-26,
SDK-pin verification, formatting, analyzer, focused tests, and the full
Flutter test suite (64 tests) passed.

`VF-005` delivery evidence: Parts 1–3 (domain contracts, transactional
persistence/hydration, bootstrap resume integration) are linked in the issue
row. Post-migration resume lookup fails closed on corrupt state; committed
session data survives file close/reopen; the app retains an optional startup
resume id for VF-006 without routing or Active Session UI. On 2026-09-26,
SDK-pin verification, formatting, analyzer, focused tests, and the full
Flutter test suite (92 tests) passed.

`VF-006` delivery evidence: Parts 1–3 (settings/shell, commit-first Cubit and
routing, tap-first set UI with explicit completion, pause/continue/finish, and
widget/router coverage) are linked in the issue row, including the part 3 UI
commit and a follow-up fix so the current set stays highlighted while save or
complete is pending. On 2026-09-26, SDK-pin verification, formatting,
`git diff --check`, analyzer, the full Flutter test suite (134 tests), and
Android debug build passed. Device VoiceOver/TalkBack, Reduce Motion, and iOS
simulator checks were not run in this environment.

`VF-007` delivery evidence: the absolute persisted rest target, commit-first
notification coordination, startup restoration, non-modal timer controls, and
local-notification platform integration are included in the linked delivery
commit. Automated coverage for notification mapping and scheduling, session
and settings persistence, Cubit behavior, startup routing, and timer controls
is linked from the issue row or included in that commit.

`VF-008` delivery evidence: calendar/schedule domain types, joined
`ScheduleRepository` range watch with add/move/skip, `PlannerCubit`, and the
week-strip Planner UI are included in the linked delivery commit. On
2026-09-26, SDK-pin verification, formatting, analyzer, the full Flutter test
suite (183 tests), and Android debug build passed. Device TalkBack/VoiceOver,
landscape week-strip, and month/year boundary checks were not run in this
environment.

`VF-009` delivery evidence: finished-session summary projections,
`watchCompletedSummaries`, History list/detail Cubits, nested
`/history/session/:sessionId` routing, and read-only Session Detail are
included in the linked delivery commit. On 2026-09-26, SDK-pin verification,
formatting, analyzer, the full Flutter test suite (217 tests), and Android
debug build passed. Device TalkBack/VoiceOver, keyboard focus on filters, and
history dates around local midnight / DST with a session timezone different
from the device zone were not run in this environment.

`VF-010` delivery evidence: reactive `watchExerciseHistory` over finished
session snapshots, Exercise History Cubit/page, nested
`/history/exercise?name=` routing with validated display names, and Session
Detail exercise headings as navigation entry points are included in the
linked delivery commit. On 2026-09-26, SDK-pin
verification, formatting, `git diff --check`, analyzer, the full Flutter test
suite (240 tests), and Android debug build passed. Device TalkBack/VoiceOver,
keyboard focus on exercise actions, and enlarged-text reflow on Exercise
History were not run in this environment.

`VF-011` delivery evidence: tokenized light/dark/system appearance selection,
SQLite-committed Settings state with retry handling, pushed Settings routing
above the four-tab shell, Today entry-point semantics, and focused Planner,
History, and Active Session accessibility adoption are included in the linked
delivery commit. On 2026-09-26, SDK-pin verification, formatting,
`git diff --check`, analyzer, the focused validation suite, the full Flutter
test suite (305 tests), and Android debug build passed. Physical Android/iOS
checks for screen readers, bold/increased contrast, reduce motion, largest
text, small-phone layout, and landscape were not run in this environment.

`VF-012` delivery evidence: versioned JSON snapshots of all seven portable
collections are read within one Drift transaction, mapped explicitly, and
shared through a private temporary file with best-effort cleanup. Settings
discloses device-only storage and plaintext sharing. On 2026-09-26,
SDK-pin verification, formatting, `git diff --check`, analyzer, the full
Flutter test suite (316 tests), and Android debug build passed. Device
share-sheet checks, including iPad popover anchoring, were not run because no
Android or iOS device or simulator was available; Flutter reported only the
Linux desktop device.

`VF-013` delivery evidence: freestyle starts commit a running, null-source
snapshot before navigation; session-local exercise/set creation is transactional
and does not mutate templates. Today and Active Session expose explicit,
accessible controls with retryable write failures. On 2026-09-29, SDK-pin
verification, formatting, `git diff --check`, analyzer, focused tests, full
coverage test suite, and Android debug build passed. Physical device/emulator,
iOS, TalkBack/VoiceOver, notification-denial, background/termination, and
largest-text manual checks were not available in this environment.

`VF-014` delivery evidence: the existing archive/restore UI and repository
coverage remain intact, and its former VF-015 dependency is now complete.
On 2026-09-30, SDK-pin verification, formatting, `git diff --check`, analyzer,
the full coverage test suite (369 tests), and Android debug build passed.
Physical Android/iOS, screen-reader, focus, and device checks remain
unverified in this environment.

`VF-015` delivery evidence: create/edit builder routes own their Cubits,
preserve the immutable template aggregate until the one-shot persistence call
commits, and keep template updates isolated from session snapshots. The
Workouts tab now has explicit app-bar and empty-state create actions; shared
committed-load formatting is used by Workouts, Active Session, and History.
On 2026-09-30, SDK-pin verification, formatting, `git diff --check`, analyzer,
focused repository/builder/router tests, the full coverage test suite (369
tests), and Android debug build passed. Physical Android/iOS, TalkBack,
VoiceOver, largest platform text, high/increased contrast, bold text, Reduce
Motion, landscape, keyboard, and small-phone checks remain unverified in this
environment.
