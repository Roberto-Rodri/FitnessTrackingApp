# DESIGN_SYSTEM.md — IronLog Visual Design System v4.0

> **Last Updated:** July 2026
> Companion to AGENTS.md (§10 UI rules) and the Project Bible. This file = visual tokens, components, and the Progress Report design spec.

---

## 1. DESIGN PHILOSOPHY
- **High contrast** — readable under gym lighting.
- **Dark-first** — warm near-black (#161412), never cool blues.
- **Warm-toned** — Ember palette: amber/gold on dark brown.
- **Thumb-friendly** — 48dp minimum touch targets.
- **Information-dense** — show what matters during a set.
- **Fast** — start a workout in ~2 taps.
- **Grayscale-safe** — never rely on color alone; pair with icons/arrows (critical for the shareable report).

---

## 2. COLOR SYSTEM (Ember Palette)
| Token | Hex | Usage |
|---|---|---|
| bg0 | #161412 | Scaffold, AppBar, full screens |
| bg1 | #231F1B | Cards |
| bg2 | #2E2923 | Dialogs, sheets, elevated surfaces |
| bg3 | #3D352C | Borders, dividers, inputs |
| amber | #E8A83E | Primary actions, data highlights |
| amberDark | #C8901A | Pressed states |
| coral | #C75D3A | Finish button, warnings, accents |
| coralDim | #7A3520 | Coral tint backgrounds |
| green | #6B9E3A | Success, checkmarks, "good" |
| greenDim | #243D12 | Green tint backgrounds |
| txt0 | #EDE6DD | Primary text |
| txt1 | #D4C4B0 | Secondary text |
| txt2 | #8A8078 | Captions, labels |
| txt3 | #5A5248 | Placeholders |
| error | #D44A3A | Destructive actions, red-flag alerts |

**Body-part colors:** Chest=amber, Back=teal #5DCAA5, Legs=purple #B488D0, Shoulders=gold #D4A84E, Arms=blue #6AADDC, Core=pink #D06A8A.

Never hardcode hex in code — use `AppTheme.*` / `Theme.of(context).colorScheme.*`.

---

## 3. TYPOGRAPHY
- **DM Sans** — all text/labels. **DM Mono** — ALL numeric data (weights, reps, %, dates, deltas).
- Key sizes: Screen title 25sp/700 · Card title 17sp/700 · Body 14sp/400 · Stat values DM Mono 22sp/500 · Input values DM Mono 22sp/600 · KPI hero value DM Mono ~46–60sp/500.

---

## 4. CORE COMPONENTS
- **Cards** — bg1, 1px bg3 border, radius 16, `PressableCard` wrapper (scale 0.975 on press, 120ms).
- **Buttons** — amber primary (height 52), coral destructive, bg3 disabled.
- **NumInput** — 56dp height, bg3→bg2 on focus, amber focus ring.
- **Dialogs / Sheets** — bg2, radius 24 (dialogs) / ~22 top corners (bottom sheets), blur overlay. Sheets/dialogs are ALWAYS solid bg2 (never transparent). Dialogs that own a `TextEditingController` must be self-contained widgets (dispose in `State.dispose()`).
- **Stat Pills** — bg1/bg2, DM Mono values, uppercase labels.
- **Body Part Tags** — pill, radius 20, per-body-part colors (`BodyPartTag`).
- **PR Badge** — amber tint (~13%), trophy icon, sm/md/lg.
- **Empty / Skeleton / Error** — 72dp icon container + CTA; shimmer 1600ms bg3→bg2; ErrorCard (inline) + ErrorScreen with retry.
- **Cycle Strip** — circular pills per day: green=completed, amber ring=current, dashed=rest.
- **Machine Picker Sheet** — bg2 sheet listing machines + "＋ Create new machine" (unique-name styled validation); attached machine shown as a small chip, removable. Machine name displayed subtly (txt2, small) on exercise cards/library rows.
- **Collapsible Metrics** — body-log "Add more metrics (optional)" section, collapsed by default (weight required; optional metrics revealed on expand).
- **Set Row** — reps LEFT / weight RIGHT with permanent unit-aware labels ("WEIGHT (kg)"); set-number box is the tappable warm-up toggle (amber "W" when active; subtle affordance border).

---

## 5. PROGRESS REPORT COMPONENTS
Shareable report; inverted-pyramid, "report by exception". Grayscale-safe (color + arrow always together).

- **Phase Badge** — pill in header; the color lens for the whole report. Cutting=coral tint, Bulking=green tint, Maintaining=amber tint. Shows an icon + phase label (DM Mono).
- **KPI Card** — bg1, radius 20; small uppercase label, large DM Mono value (+unit), and a **Delta chip**: colored pill with a direction ARROW (↑ ↓ ↔) + value. Color is **phase-aware clinical meaning**, never raw direction:
    - Cutting: weight ↓ = green, ↑ = red.
    - Bulking: weight ↑ = green, ↓ = red.
    - Maintaining: ~0 = green, drift >0.5%/wk = red.
    - none = neutral. Arrows shown in all cases.
- **Alert Row** — high-contrast, left accent bar (4px) + icon. Warning = error red (#D44A3A) with warning icon; "good"/all-clear = green with check. Concise text.
- **Stratum Divider** — mono index (01–04) + uppercase title + optional focus tag ("trainer" / "nutritionist") + thin rule.
- **Passive Hint** — subtle one-line row (info icon + txt2) replacing a COLLAPSED empty section (e.g. "Log your waist measurement to unlock recomposition analysis"). Never show "No Data" boxes.

### Chart styles (custom `CustomPainter`, no chart package)
- **Weight Trend** — thick amber (EMA) line + faint low-opacity raw-weigh-in dots behind it. Sparse variant (<3 logs/wk): straight slope between first/last points + a "SPARSE DATA" tag; KPI relabels to "Raw Weight Change".
- **Recomposition** (conditional) — synchronized X-axis line(s) for waist / body-fat %; collapses to a passive hint when absent.
- **Effective Sets/Muscle** — horizontal bars per body part; faint vertical reference lines at **MEV 10** and **MRV 20** with small labels.
- **e1RM Trend** — multi-line, one amber-family line per tracked lift (top 2–3).

---

## 6. ANIMATIONS
Checkmark pop (350ms elastic), row flash (1200ms), PR badge pop (400ms delayed), drag lift (150ms scale), drag drop (200ms spring), tab fade (180ms), card press (120ms), workout-finish bounce (400ms elastic), confetti burst (staggered), skeleton shimmer (1600ms linear), dialog fadeIn (200ms).
(Rest-timer slide animations removed with the rest-timer feature.)

---

## 7. HAPTIC FEEDBACK
Set logged=Medium · PR=Success(double) · Drag start=Medium · Drag snap=Light · Delete=Heavy · Exercise added=Light · Workout start=Medium · Workout finish=Success · Error=Heavy · Dialog save=Light. Via `HapticFeedback` (`services.dart`) — built-in API, not a package.

---

## 8. SCREENS (13+)
Splash · Home (dashboard + program-aware) · ActiveWorkout · WorkoutHistory · SessionDetail · WorkoutSummary (post-workout comparison) · RoutineList (+programs) · RoutineEdit · ExerciseSelection · ExerciseLibrary · ProgramEdit (+template picker) · BodyWeightHistory · **ProgressReport**.

---
*End of DESIGN_SYSTEM.md v4.0*