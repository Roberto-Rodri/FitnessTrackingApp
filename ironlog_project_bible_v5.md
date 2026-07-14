# IronLog — Project Bible v5.0

> **Last Updated:** July 2026
> **Companion to AGENTS.md.** AGENTS.md = binding rules/conventions. This Bible = what exists, where it lives, and current status. Read both.

---

## 0. SOURCE OF TRUTH
Every agent prompt begins: *"Read AGENTS.md at the project root. It is the single source of truth for this project."*

---

## 1. PROJECT IDENTITY
- **App:** IronLog — offline-first Flutter strength-training tracker. Package `iron_log`.
- **Repo:** https://github.com/Roberto-Rodri/FitnessTrackingApp
- **Stack:** Flutter (Dart ≥3.8) · Clean Architecture · **Riverpod 3.x** · **Freezed 3.x** · go_router (StatefulShellRoute, 3 tabs) · sqflite · Material 3 (Ember dark theme) · DM Sans + DM Mono · custom `CustomPainter` charts.
- **Key packages:** `share_plus`, `path_provider`, `google_fonts`, `shared_preferences`, `flutter_launcher_icons` (dev).
- **Tooling:** Antigravity (coding agent) · Gemini (prompt-writing / coordination) · design tool (UI mockups).
- **Environments:** Windows + macOS (M4); Android + iOS targets. Data is on-device SQLite — git carries code, NOT workout data (move data via in-app Export/Import).

---

## 2. FEATURE SET (current)

### Core / v1
- **Training Programs** — multi-day cycles, templates (PPL, Upper/Lower, Full Body), effort-based auto-advancement, rest days, override support. One active program at a time.
- **Active Workout** — start → pick routine or program suggestion → log sets → finish with confetti. Workout duration timer (counts up).
- **Weight Units** — per-exercise kg / lbs / plates / custom.
- **Best + Latest / Global vs Routine** — PR and latest set per exercise; toggle all-time vs routine-specific.
- **Per-set previous-session hint** — "Prev: w × r" under each set.
- **Exercise Alternatives** — link + quick-swap during workout.
- **PR Detection** — real-time, badge animation, PR counts on history.
- **Workout History / Session Detail** — sessions with duration/volume/sets; filter All/Week/Month; delete; grouped sets, volume chart, PR badges, RPE.
- **Post-workout summary** — per-exercise volume comparison vs last time, phase-aware coloring + greetings.
- **Routine & Exercise CRUD** — reorder, edit targets, search, duplicate check, deletion warnings.
- **Dashboard / Profile** — first-launch name prompt, greeting, weekly stats, volume chart, recent workouts, program-aware "Next up".
- **Polish** — empty/skeleton/error states, animations, 17 haptic points, app icon + animated splash.

### v2 additions (all complete)
- **Body Metrics** — weight required; optional body fat %, muscle mass, waist, chest, arms, notes (collapsible "add more metrics").
- **Reps/weight swap + unit-aware labels** — reps LEFT, weight RIGHT, permanent labels.
- **Phase-aware rep-target feedback** — logged sets colored green (met range top) / neutral / coral (short of range bottom by phase threshold: cut 3 / maintain 2 / bulk 1). Warm-ups exempt.
- **Warm-up discoverability** — tap the set-number box to toggle warm-up; visual cue + one-time hint.
- **Mid-workout exercise ops** — create new OR add existing exercise (session-only, targets, styled alerts); create-from-swap; all session-only (routine unchanged).
- **Machine labels** — reusable `machines` table, opt-in per exercise, attach/create in Library or mid-workout.
- **Mid-workout weight-unit change** — today-only vs permanent; already-logged sets keep original unit.
- **Superset per-exercise unlink** (bottom-left of card).
- **Backup / Export + Import** — JSON via `share_plus`; dynamically covers all tables; backward-compatible.
- **Workout / IG image share** — RepaintBoundary → PNG → share sheet.
- **Progress Report** (see §5).

### Removed
- **Rest Timer** — fully removed (locked-screen vibration never worked); duration timer kept. No rest-timer widget, no `restSeconds`, no notification/vibration/timezone packages.

---

## 3. CODE FOOTPRINT
~60+ authored Dart files across **5 features** (profile, program, progress, splash, workout) + core infra. Feature-first structure (see AGENTS.md §3).

---

## 4. DATABASE
`sqflite`. Version: **[read `_databaseVersion` in database_helper.dart]** (bumped for machines, body-metrics expansion, restSeconds removal). **10 tables:** exercises (+machineId), machines, routines, routine_exercise_cross_ref (no restSeconds), workout_sessions, workout_sets, exercise_alternatives, programs, program_days, body_weight_logs (+6 metric columns). Full schema in AGENTS.md §5.

---

## 5. PROGRESS REPORT (flagship v2 feature)
Shareable analytical report for a coach (trainer + nutritionist), weekly default + custom date range. Full-screen route `/progress-report`.
- **Design:** approved 4-strata inverted-pyramid mockup — Header + phase badge → KPI grid → weight-trend + recomposition charts → effective-sets + e1RM charts → alerts/PRs/notes. Phase badge is the color lens.
- **Metrics:** e1RM (Brzycki, ≤10 reps), EMA trend weight (alpha 0.15) with sparse fallback (<3 logs/wk), weekly rate-of-change, effective sets/muscle (MEV 10/MRV 20), adherence %, consistency, PRs, body-comp trends, phase-aware red-flag alerts.
- **Status:** Part 1 (calculations) ✅ tested · Part 2 (UI) ✅ on-device · **Part 3 (export to PDF/image) — PENDING**.

---

## 6. DEVELOPMENT HISTORY
| Era | Milestones |
|---|---|
| Foundation | Audit, P0–P6 bug fixes, DI refactor, error handling |
| Core (F1–F10) | Dynamic exercises, swap, history, routine/library CRUD, weight units, best+latest, global/routine toggle, alternatives |
| Design Overhaul | Ember palette, bottom nav, profile, dashboard, all screens |
| Programs | Data → widgets → cycle advancement → templates |
| Polish | Empty/skeleton/error states, PR detection, animations, haptics, icon+splash |
| **v2** | PR fix, edit sets, **rest timer removed**, body metrics, reps/weight swap, phase-aware feedback, warm-up discoverability, mid-workout exercise/machine/unit ops, backup+share fixes |
| **Toolchain** | **Freezed 3.x / Riverpod 3.x migration** (Dart 3.11 SDK), stale-test + crash fixes |
| **Progress Report** | Deep research → design mockup → Part 1 (calc) → Part 2 (UI); Part 3 pending |

---

## 7. CURRENT STATUS & PHASE PLAN
- **PHASE A — Finish Report:** Part 3 (export to shareable PDF/image; reuse share_plus + path_provider, RepaintBoundary). ← immediate next.
- **PHASE B — Housekeeping:** keep AGENTS.md/Bible current; fix Paste-JSON-Backup controller leak (`profile_settings_screen.dart`); clear residual lint.
- **PHASE C — Full QA pass:** whole-app bug hunt.
- **PHASE D — Backlog (Future Features):**
    - *NEAT / Daily Steps:* Add a simple daily step tracker to contextualize weight loss stalls.
    - *Sleep / Recovery Score:* Add a 1-10 subjective RPE for daily energy/sleep to explain fluctuations in e1RM and volume.
    - *Body Fat % Tracking Adjustments:* Restrict logging frequency to weekly or apply aggressive smoothing to prevent daily fluctuation anxiety.
---

## 8. WORKING NORMS
- Antigravity prompts start with "Read AGENTS.md…" + the PACKAGE RULE (agent must STOP and ASK before any package change).
- Verify before commit: `dart analyze` = 0 AND `flutter build apk --debug` compiles AND tests/runtime confirmed for behavior. Never trust an agent's "done" over a device test.
- DB-touching work: safe migration + export a backup first.
- Uploads to chat often arrive empty — paste content as text/code blocks.

---
*End of Project Bible v5.0*