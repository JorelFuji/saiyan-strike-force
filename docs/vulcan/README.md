# Vulcan Fitness — App Specification

**Platform:** iOS & Android (mobile only)
**Target user:** Advanced athletes running self-programmed strength training
**Version:** v1.0 Spec (revised)
**Date:** September 10, 2026
**Status:** Implementation-ready for data model and Active Session; UI build starts after those are in place

This revision incorporates a product-spec review. Positioning, core loop, information architecture, visual direction, local-first stance, and Cubit/`flutter_bloc` + MVVM are unchanged. The data model, session lifecycle, Active Session interaction, units, accessibility, and v1 scope are now explicit. On 2026-09-17 the package baseline, target folders, constructor-injection DI, and UI-library decision were revised in [architecture.md](architecture.md); product non-goals are unchanged.

---

## Product Overview

Vulcan Fitness is a Flutter strength-training app for lifters who already know how to program their own training and just need a fast, precise, distraction-free tool to plan it, run it, and see it. No exercise database to browse, no AI coach, no social feed, no nutrition log — just workout building, week/month planning, live session logging, and history, wrapped in a neumorphic, Nord-inspired interface.

### Explicit non-goals (v1)
- No built-in exercise library / curated autocomplete database
- No AI-generated programming or suggestions
- No social features (feeds, sharing, following)
- No nutrition tracking
- No web or desktop client
- No cloud backup or cross-device sync
- No import of exported files
- No Apple HealthKit or Google Health Connect integration
- No accent-color customization
- No analytics dashboard / multiple chart types
- No wearable-specific experiences

---

## Target User

**Persona: "The Self-Coached Lifter"**
Trains 3–6x/week on a structured strength program (e.g., 5/3/1, a block periodization cycle, a powerlifting peaking plan) that they've written themselves or copied from a coach into their own words. They think in terms of sets, reps, load, perceived exertion (RPE), and weekly/monthly structure — not "browse chest exercises." They want:
- To build a workout in under 5 minutes, using their own exercise names and notation
- To log a session fast, mid-set, without fumbling the UI — often one-handed, sweaty, looking away from the device
- To look back at a lift's history at a glance ("what did I do last time?")
- Accessibility: OS text scaling through the largest Dynamic Type / Android font-scale steps, contrast that meets WCAG, VoiceOver/TalkBack, Reduce Motion, bold text, and high-contrast settings where the OS supports them

See [accessibility.md](accessibility.md) for measurable a11y requirements.

---

## Core Workflow

The app is built around one primary loop, repeated weekly/monthly:

```
PLAN → SCHEDULE → PERFORM → REVIEW
```

1. **Plan** — Build reusable Workout templates (e.g., "Squat Day A") with exercises, target sets/reps/load, and rest.
2. **Schedule** — Place those workouts onto a week calendar (month is a lightweight overview), unlimited workouts, unlimited scheduling.
3. **Perform** — Start a session (from the plan, or ad hoc), log actual sets/reps/weight/RPE as you go, with a rest timer that is not modal. Have a total time from start to finish.
4. **Review** — See history per exercise first, then per session.

Every major feature maps to one of those four jobs. Preserve that.

---

## Information Architecture

Bottom navigation, 4 destinations (mobile-standard, thumb-reachable):

```
┌─────────────────────────────────────────────┐
│                                               │
│                 Screen Content                │
│                                               │
├─────────┬─────────┬─────────┬────────────────┤
│  Today  │ Planner │ History │    Workouts     │
│  (home) │ (cal.)  │ (log)   │  (templates)    │
└─────────┴─────────┴─────────┴────────────────┘
```

- **Today** — launch surface: what's scheduled today, quick "Start Workout," streak/adherence snapshot, jump into an unscheduled/freestyle session.
- **Planner** — week view is the operational planner; month view is a structural overview (dots, not detail).
- **Workouts** — library of *your* workout templates (unlimited); create/edit/duplicate/archive.
- **History** — chronological log of completed sessions; the fastest path is per-exercise progression.

A **Settings** screen is reached via icon from Today, not a 5th tab.

Full screen list: [screens.md](screens.md).

---

## Doc map

| Doc | When to open |
|---|---|
| [invariants.md](invariants.md) | Product contracts that must never be violated |
| [screens.md](screens.md) | Screen inventory |
| [features/templates.md](features/templates.md) | Workout template builder |
| [features/planner.md](features/planner.md) | Week/month scheduling |
| [features/active-session.md](features/active-session.md) | Session lifecycle, snapshot, logging UI, rest timer |
| [features/history.md](features/history.md) | Session list and exercise progression |
| [features/privacy-export.md](features/privacy-export.md) | Local-first data and export |
| [design.md](design.md) | Visual language, tokens, motion, gestures |
| [accessibility.md](accessibility.md) | Contrast, scaling, assistive tech |
| [architecture.md](architecture.md) | Flutter stack, MVVM, folder layout |
| [data-model.md](data-model.md) | SQLite schema, units, encryption |
| [roadmap.md](roadmap.md) | P0/P1/P2, deferred work, closed decisions |
