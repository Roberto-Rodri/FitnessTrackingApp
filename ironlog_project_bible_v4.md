# IronLog — Project Bible v4.0

> **Last Updated:** April 27, 2026

---

## 0. AGENTS.md IS THE SOURCE OF TRUTH

Every prompt must begin with:
> "Read AGENTS.md at the project root. It is the single source of truth for this project."

---

## 1. PROJECT IDENTITY

**App Name:** IronLog
**Repository:** https://github.com/Roberto-Rodri/FitnessTrackingApp
**Stack:** Flutter | Clean Architecture | Riverpod 2.x | go_router | sqflite v6 | freezed | Material Design 3 (Ember)
**Dev Tools:** Antigravity (coding agent), Claude Design (UI/UX), Claude Project (coordination)

---

## 2. COMPLETE FEATURE SET

| Feature | Description |
|---------|-------------|
| Training Programs | Multi-day cycles with templates (PPL, Upper/Lower, Full Body), auto-advancement, rest days, override support |
| Active Workout | Start → pick routine (or program suggestion) → log sets → swap exercises → finish with confetti |
| Rest Timer | Auto-start after logging, configurable per exercise, arc progress, urgent state at ≤10s |
| Weight Units | Per-exercise: kg, lbs, plates, custom text labels |
| Best + Latest | PR and most recent set shown per exercise during workout |
| Global vs Routine | Toggle between all-time latest or routine-specific latest |
| Exercise Alternatives | Link exercises as alternatives, quick-swap during workout |
| PR Detection | Real-time PR computation, badge pop animation, "New PR!" in rest timer, PR count on history cards |
| Workout History | Completed sessions with duration, volume, sets. Filter by All/This week/This month. Delete sessions. |
| Session Detail | Grouped sets by exercise, volume bar chart, PR badges, RPE display |
| Routine Management | Full CRUD, drag-to-reorder exercises, edit targets (sets/reps/rest), exercise selection with search |
| Exercise Library | Full CRUD, autocomplete body parts, duplicate check, deletion warnings with usage/history counts |
| Ember Theme | Warm amber/gold palette, DM Sans + DM Mono typography, body part color tags |
| Bottom Navigation | 3 tabs (Home, Routines, History) via StatefulShellRoute |
| Profile / Greeting | First-launch name prompt, personalized dashboard greeting |
| Dashboard | Weekly stats, volume chart, recent workouts, quick-start card, program-aware "Next up" |
| Empty States | Designed states with icons + CTAs for history, routines, search, library |
| Skeleton Loading | Shimmer cards replacing CircularProgressIndicator across all screens |
| Error States | ErrorCard (inline) + ErrorScreen (full-screen) with retry buttons |
| Animations | 12 animations: checkmark pop, row flash, PR badge, drag lift/drop, tab fade, card press, workout finish, confetti |
| Haptic Feedback | 17 interaction points mapped to light/medium/heavy/success patterns |
| App Icon + Splash | Flame + barbell mark, animated splash screen |

---

## 3. FILE COUNT

~50+ authored Dart files across 4 features (profile, program, splash, workout) + core infrastructure.

---

## 4. DATABASE

Version 6. 8 tables: exercises, routines, routine_exercise_cross_ref, workout_sessions, workout_sets, exercise_alternatives, programs, program_days.

---

## 5. DEVELOPMENT HISTORY

| Phase | Milestones |
|-------|-----------|
| Foundation | Audit, 6 bug fixes (P0–P6), DI refactor, error handling |
| Core Features | Dynamic exercises (F1), Swap (F2), History (F3), Routine CRUD (F4), Exercise Library (F5) |
| Advanced Features | Rest timer (F6), Weight units (F7), Best+Latest (F8), Global/Routine toggle (F9), Alternatives (F10) |
| Design Overhaul | Ember palette (D1–D10), bottom nav, profile, dashboard, all screens redesigned |
| Programs | Data foundation, widgets, integration, cycle advancement, templates, bug fixes |
| Polish | Empty/skeleton/error states (P1–P2), PR detection (P3), animations (P4), haptics (P5), icon+splash (P6) |
| Final | Delete program/session, testing, doc updates |

---

*End of Project Bible v4.0*
