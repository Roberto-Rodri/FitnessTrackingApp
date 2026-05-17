# DESIGN_SYSTEM.md — IronLog Visual Design System v3.0

> **Last Updated:** April 27, 2026

---

## 1. DESIGN PHILOSOPHY

- **High contrast** — readable under gym lighting
- **Dark-first** — warm near-black (#161412), never cool blues
- **Warm-toned** — Ember palette: amber/gold on dark brown
- **Thumb-friendly** — 48dp minimum touch targets
- **Information-dense** — show what matters during a set
- **Fast** — start workout in 2 taps

---

## 2. COLOR SYSTEM (Ember Palette)

| Token | Hex | Usage |
|-------|-----|-------|
| bg0 | #161412 | Scaffold, AppBar |
| bg1 | #231F1B | Cards |
| bg2 | #2E2923 | Dialogs, elevated surfaces |
| bg3 | #3D352C | Borders, dividers, inputs |
| amber | #E8A83E | Primary actions, data highlights |
| amberDark | #C8901A | Pressed states |
| coral | #C75D3A | Finish button, accents |
| coralDim | #7A3520 | Coral tint backgrounds |
| green | #6B9E3A | Success, checkmarks |
| greenDim | #243D12 | Green tint backgrounds |
| txt0 | #EDE6DD | Primary text |
| txt1 | #D4C4B0 | Secondary text |
| txt2 | #8A8078 | Captions, labels |
| txt3 | #5A5248 | Placeholders |
| error | #D44A3A | Destructive actions |

### Body Part Colors
Chest=amber, Back=teal(#5DCAA5), Legs=purple(#B488D0), Shoulders=gold(#D4A84E), Arms=blue(#6AADDC), Core=pink(#D06A8A)

---

## 3. TYPOGRAPHY

**DM Sans** — all text. **DM Mono** — all numeric data.

Key sizes: Screen title 25sp/700, Card title 17sp/700, Body 14sp/400, Stat values DM Mono 22sp/500, Input values DM Mono 22sp/600.

---

## 4. COMPONENTS

- **Cards:** bg1, 1px bg3 border, radius 16, PressableCard wrapper (scale 0.975 on press)
- **Buttons:** Amber primary (height 52), coral destructive, bg3 disabled
- **NumInput:** 56dp height, bg3→bg2 on focus, amber focus ring
- **Dialogs:** bg2, radius 24, blur overlay
- **Stat Pills:** bg1/bg2, DM Mono values, uppercase labels
- **Body Part Tags:** Pill shape, radius 20, per-body-part colors
- **PR Badge:** Amber tint (13%), trophy icon, sm/md/lg sizes
- **Empty State:** 72dp icon container, headline, subtitle, optional CTA
- **Skeleton Bone:** Shimmer animation 1600ms, bg3→bg2 gradient
- **Error Card:** bg1, coral border, warning icon, retry button
- **Cycle Strip:** Circular pills per day, green=completed, amber ring=current, dashed=rest

---

## 5. ANIMATIONS (12 implemented)

Checkmark pop (350ms elastic), Row flash (1200ms), PR badge pop (400ms delayed), Drag lift (150ms scale), Drag drop (200ms spring), Tab fade (180ms), Card press (120ms), Workout finish bounce (400ms elastic), Confetti burst (8 particles, staggered), Skeleton shimmer (1600ms linear), Dialog fadeIn (200ms), Rest timer slideUp/Down.

---

## 6. HAPTIC FEEDBACK (17 points)

Set logged=Medium, PR=Success(double-tap), Timer skip=Light, Timer expired=Medium, Drag start=Medium, Drag snap=Light, Delete=Heavy, Exercise added=Light, Workout start=Medium, Workout finish=Success, Error=Heavy, Dialog save=Light.

---

## 7. SCREENS (10 total)

SplashScreen, HomeScreen (dashboard + program-aware), ActiveWorkoutScreen, WorkoutHistoryScreen, SessionDetailScreen, RoutineListScreen (+ programs section), RoutineEditScreen, ExerciseSelectionScreen, ExerciseLibraryScreen, ProgramEditScreen (+ template picker).

---

*End of DESIGN_SYSTEM.md v3.0*
