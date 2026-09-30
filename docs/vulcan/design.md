# Design Language

Neumorphic, Nord-influenced UI tokens, motion, and gestures. Contrast requirements: [accessibility.md](accessibility.md).

---

## Direction

**Neumorphism, Nord-influenced, with a warm custom base — not textbook Nord, not textbook neumorphism.** Two adjustments:
1. Shadows are **soft and directional**, not symmetric embossed blobs — a single dominant light source (top-left), subtle, low-opacity.
2. Neumorphism is used selectively — primary surfaces (cards, buttons, high-frequency controls) get the soft-UI treatment; dense data (history lists, numeric tables, set rows) stays flat for legibility.

Shadows and glows outside a component are **not** sufficient focus/state indication (WCAG 2.2 focus appearance). Interactive state must use an actual border and/or accent change on the component itself.

## Color System — dark and light from the start

Do not build dark mode first and invert it later. Design tokens must support dark, light, semantic states, accessible control boundaries, and large text from day one.

**Dark (default)**

| Token | Hex | Role |
|---|---|---|
| `bg.base` | `#22201F` | App background |
| `bg.surface` | `#282624` | Raised card surface |
| `bg.surfaceSunken` | `#1C1A19` | Inset/pressed surface |
| `shadow.dark` | `#141312` | Neumorphic dark shadow (bottom-right) |
| `shadow.light` | `#302D2B` | Neumorphic light shadow (top-left) |

**Light** — Nord Snow Storm base, inverted shadow logic:

| Token | Hex | Role |
|---|---|---|
| `bg.base` | `#ECEFF4` | App background (nord6) |
| `bg.surface` | `#E5E9F0` | Raised card (nord5) |
| `bg.surfaceSunken` | `#D8DEE9` | Inset/pressed (nord4) |
| `shadow.dark` | `#B8C0CC` | Dark shadow |
| `shadow.light` | `#FFFFFF` | Light shadow |

**Accents** (same in both themes — Nord Frost/Aurora):

| Token | Hex | Nord ref | Role |
|---|---|---|---|
| `accent.primary` | `#88C0D0` | nord8 | Primary actions, active states, selected day |
| `accent.primaryDeep` | `#5E81AC` | nord10 | Pressed state, secondary emphasis |
| `state.success` | `#A3BE8C` | nord14 | Completed set/session, "on track" |
| `state.warning` | `#EBCB8B` | nord13 | Rest-timer mid-state, derived "missed" |
| `state.danger` | `#BF616A` | nord11 | Delete, skipped |
| `state.highlight` | `#D08770` | nord12 | Streaks, PRs |

**Dark text**

| Token | Hex | Role |
|---|---|---|
| `text.primary` | `#EDEAE6` | Primary text (warm-white) |
| `text.secondary` | `#A8A29B` | Secondary/meta |
| `text.disabled` | `#6B655F` | Disabled/placeholder (Nord reference) |
| `text.onAccent` | `#12181B` | Text on Frost-blue accents |

**Light text** (implemented in `lib/ui/core/theme/vulcan_theme.dart`):

| Token | Hex | Role |
|---|---|---|
| `text.primary` | `#2E3440` | Primary text |
| `text.secondary` | `#4C566A` | Secondary/meta |
| `text.disabled` | `#5E6674` | Disabled/placeholder |
| `text.onAccent` | `#FFFFFF` | Text on deep interactive primary (`#3B5B7F`) |

Contrast requirements in [accessibility.md](accessibility.md) apply to both themes. Where a Nord reference hex fails 4.5:1 on its immediate background, the theme code uses a contrast-adjusted value and documents it in source (for example dark `text.disabled` → `#9A938C`, light interactive primary → `#3B5B7F` instead of Frost on Snow Storm). **`state.danger` (`#BF616A`)** remains the brand reference; **`ColorScheme.error`** (inline error text on surfaces) and **`VulcanColors.danger`** (destructive fills) use deeper reds defined in the theme files so paired foregrounds pass automated contrast tests.

Accent-color picker is **out of v1**. The Nord palette is the visual identity. Theme setting is dark / light / system only.

## Typography

**Manrope** is the typeface (confirmed). Tabular figures, numeral treatment, text scaling, and spacing matter more than the font choice.

| Style | Font | Weight | Use |
|---|---|---|---|
| Display | Manrope | 800 | Session/workout titles |
| Heading | Manrope | 700 | Section headers |
| Body | Manrope | 500 | General UI text |
| Numeral (stat) | Manrope (tabular) | 700 | Reps/weight/timer displays |
| Caption | Manrope | 500 | Meta/secondary text |

## Elevation & Shape

- Corner radius: 20px for cards/major surfaces, 14px for buttons/chips, 999px (full round) for the primary FAB-style "Start Workout" control and set-complete checkmarks.
- Neumorphic shadow pairs at low opacity (~35–45%), blur 12–16px, offset 6–8px — soft, not deep-carved. Dense set rows are flat; they do not use neumorphic shadows.
- Two elevation states per interactive neumorphic surface: **raised** (default) and **pressed/inset**. Pair with an accent border/focus ring so state does not depend on shadow perception.

## Implementation

Apply these tokens through Material 3 `ThemeData`, `ColorScheme`, component themes, and a `ThemeExtension` (for example `VulcanColors`). Flutter Material 3 widgets are the behavioral foundation (focus, semantics, text scaling, `NavigationBar`, buttons, fields, dialogs, snackbars).

Selective neumorphism is custom — an owned `VulcanSurface` (and similar primitives under `lib/ui/core`), not a pub.dev neumorphic kit. Do **not** add `flutter_neumorphic*`, a general calendar package, or a form-builder. Week strip and month-dot grid are in-repo widgets using Flutter date helpers.

Shadows and glows are not focus. Interactive state still uses an actual border and/or accent change on the component itself, as specified under Direction. Folder and package rules: [architecture.md](architecture.md) UI library.

## Motion

Minimal, purposeful, tied to state changes:
- **Press feedback:** 100–120ms ease-out scale (0.97) + shadow inversion on neumorphic surfaces.
- **Set completion:** 150ms checkmark scale-in + `HapticFeedback.lightImpact`.
- **Rest timer:** thin circular progress ring, remaining time derived from `rest_target_at`.
- **Screen transitions:** platform-default.
- **Calendar day selection:** 150ms color/scale morph on the selected day chip.
- Respect OS reduce-motion everywhere.

## Gestures

Principle: in a strength-training app, accidental input is worse than one extra tap. The user is often sweaty, one-handed, holding a weight, or looking away.

| Gesture | Where | Action |
|---|---|---|
| Tap | Everywhere | Primary action (including set complete) |
| Long-press + drag | Workout builder exercise list; Planner (secondary) | Reorder exercises; drag a template onto a date |
| Horizontal swipe | Planner week strip | Previous/next week |
| Edge swipe back | All pushed screens | OS-native back |

**Removed from v1:** swipe-to-complete, swipe-to-delete on set rows, double-tap to edit, horizontal swipe between exercise cards as primary navigation.

Destructive actions use an explicit control plus Undo snackbar (preferred) or confirm.

Active Session interaction model: [features/active-session.md](features/active-session.md).
