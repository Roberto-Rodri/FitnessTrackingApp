# AGENTS.md — IronLog Project Rules

> **Single source of truth for this project.** Every AI agent MUST read this before writing, modifying, or suggesting code.
> If a user instruction contradicts this file, ask for clarification — do not silently override.

---

## 1. PROJECT OVERVIEW
**IronLog** — offline-first Flutter strength-training tracker. Builds for Android + iOS (developed on Windows + macOS). Strict Clean Architecture, Riverpod state, SQLite persistence.

**Workflow:** AI-assisted. Human is Lead Architect. Agent writes implementation code per these rules. Package name: `iron_log`.

---

## 2. TECH STACK
| Component | Technology |
|---|---|
| Framework | Flutter · Dart **>=3.8.0 <4.0.0** |
| Architecture | Clean Architecture (Presentation → Domain ← Data) |
| State | **Riverpod 3.x** (`@riverpod`, base `Ref`, `AsyncNotifier`) |
| Models | **Freezed 3.x** (`abstract`/`sealed`) + `json_serializable` |
| Codegen | `build_runner`, `riverpod_generator`, `freezed` |
| Routing | `go_router` + `StatefulShellRoute` |
| Database | `sqflite` (see §5 for version) |
| Sharing/Files | `share_plus`, `path_provider` |
| Typography | `google_fonts` (DM Sans + DM Mono) |
| Prefs | `shared_preferences` (user name, training phase, one-time hints) |
| UI | Material 3 · Ember dark theme |
| Icons | `flutter_launcher_icons` (dev) |

**Build command:** `dart run build_runner build --delete-conflicting-outputs`
(If your build_runner rejects the flag, use `dart run build_runner build`.)

### 2.1 Framework-Version Conventions (CRITICAL — do not regress)
- **Freezed 3.x:** every `@freezed` class is declared `abstract class X with _$X` (single-constructor data classes). Use `sealed class` only for unions (multiple factory constructors). NEVER use the old 2.x `class X with _$X`.
- **Riverpod 3.x:** `@riverpod` functions/classes take the base `Ref` (NOT generated `XxxRef`). No manual `NotifierProvider`. On an `AsyncNotifier`, read a derived value via `.valueOrNull` (the old `.select()` pattern changed).
- Regenerating with the wrong syntax causes ~90 analyzer errors ("Missing `_$X` impls", "Undefined `XxxRef`"). Match the 3.x syntax.

---

## 3. FOLDER STRUCTURE (feature-first)
```
lib/
├── core/{database/database_helper.dart, di/injection.dart,
│         routing/router.dart, theme/theme.dart,
│         widgets/{app_shell.dart, pressable_card.dart}, database/backup_providers.dart}
├── features/
│   ├── profile/{data, domain, presentation/{controllers/profile_providers.dart,
│   │            screens/profile_settings_screen.dart, widgets/name_prompt_dialog.dart}}
│   ├── program/{data, domain/entities/{program, program_day, program_detail}.dart,
│   │            presentation/{controllers/program_providers.dart,
│   │            screens/program_edit_screen.dart, widgets/*}}
│   ├── progress/                         # PROGRESS REPORT feature
│   │   ├── data/{datasources/progress_local_data_source.dart,
│   │   │         repositories/progress_repository_impl.dart}
│   │   ├── domain/{entities/progress_report_data.dart,
│   │   │           calculations/progress_calculations.dart,
│   │   │           repositories/progress_repository.dart}
│   │   └── presentation/{controllers/progress_providers.dart,
│   │                     screens/progress_report_screen.dart}
│   ├── splash/presentation/screens/splash_screen.dart
│   └── workout/
│       ├── data/{datasources/workout_local_data_source.dart, repositories/...}
│       ├── domain/entities/{body_weight_log, exercise, machine, routine,
│       │        routine_exercise, routine_exercise_detail, routine_summary,
│       │        weekly_stats, workout_session, workout_session_summary,
│       │        workout_set, workout_summary_detail, exercise_history_summary}.dart
│       └── presentation/
│           ├── controllers/workout_providers.dart
│           ├── screens/{home, active_workout, workout_history, session_detail,
│           │           routine_list, routine_edit, exercise_selection,
│           │           exercise_library, body_weight_history, workout_summary}_screen.dart
│           └── widgets/{active_exercise_card, comparison_panel, edit_targets_dialog,
│                       exercise_form_dialog, exercise_swap_sheet, quick_swap_sheet,
│                       machine_picker_sheet, add_exercise_targets_dialog,
│                       log_weight_sheet, body_weight_card, workout_status_bar,
│                       pr_badge, body_part_tag, share_overlay_screen, ...}
└── main.dart
```
Note: rest-timer widget was REMOVED (see §11).

---

## 4. CLEAN ARCHITECTURE (MANDATORY)
```
Presentation → Domain ← Data ;  Core shared by all
```
- **Presentation** imports Domain + Core only. NEVER Data.
- **Data** implements Domain interfaces; imports Domain + Core.
- **Domain** imports nothing (pure Dart). Calculations live here.
- **Core** = shared infra, importable anywhere.
- DI: Data implementations instantiated ONLY in `core/di/injection.dart`.

---

## 5. DATABASE SCHEMA
SQLite via `sqflite`. Version: **[CURRENT — read `_databaseVersion` in database_helper.dart]**. FKs enabled. Bumped several times (machines, body-metrics expansion, restSeconds removal).

### Tables
- **exercises** — id, name, bodyPart, weightUnit (default 'kg'), **machineId** (INTEGER, nullable, FK → machines.id ON DELETE SET NULL)
- **machines** — id (INTEGER PK AUTOINCREMENT), name (TEXT UNIQUE)
- **routines** — id, name
- **routine_exercise_cross_ref** — routineId (FK CASCADE), exerciseId (FK CASCADE), sequenceOrder, targetSets, targetReps, supersetGroup (INTEGER, nullable). **NOTE: `restSeconds` was REMOVED — do not reference it.**
- **workout_sessions** — id, startTimestamp, endTimestamp, routineId, routineNameSnapshot, notes (nullable)
- **workout_sets** — id, sessionId (FK CASCADE), exerciseId (FK CASCADE), weight, reps, rpe, customWeight, isWarmup (INTEGER DEFAULT 0)
- **exercise_alternatives** — exerciseId1, exerciseId2 (both FK CASCADE, composite PK, id1 < id2)
- **programs** — id, name, cycleLengthDays, isActive, currentDayIndex
- **program_days** — id, programId (FK CASCADE), dayIndex, routineId (FK SET NULL), label
- **body_weight_logs** — id (TEXT PK), timestamp (INTEGER), weight (REAL), **bodyFatPercentage, muscleMass, waist, chest, arms (all REAL nullable), notes (TEXT nullable)**

### Rules
- Always bump `_databaseVersion` + add `onUpgrade`. Never wipe/recreate tables with data. Use ALTER TABLE ADD COLUMN (safe) or the table-rebuild-in-transaction pattern where needed.
- Warm-up sets (`isWarmup = 1`) excluded from PR/volume/target/e1RM counts.
- Superset = exercises sharing a non-null `supersetGroup` in a routine.

---

## 6. RIVERPOD RULES
- `@riverpod` annotation; base `Ref`. Infra providers `keepAlive: true` in `injection.dart`.
- Never `ref.read` in `build()` — use `ref.watch`. Invalidate affected providers after mutations.
- `WorkoutSessionNotifier` uses `_isStarting` flag (NOT `state.isLoading`) for double-click prevention.
- `startSession()` internally loads exercises, best/latest sets, per-set previous-session data, alternatives, and prior notes before completing.

### Invalidation Map
| Mutation | Invalidate |
|---|---|
| Create/edit/delete exercise | `allExercisesProvider`, `bodyPartsProvider`, `routineListProvider` |
| Attach/clear/create machine | machines list provider + `allExercisesProvider` (+ exercise/library views) |
| Create/edit/delete routine | `routineListProvider` (+ `routineEditorProvider` when editing) |
| End session | `completedSessionsProvider`, `weeklyStatsProvider`, `weeklyVolumeChartProvider`, `recentSessionsProvider` |
| End session (program) | Above + `allProgramsProvider`, `activeProgramProvider`, `currentProgramDayProvider`, `completedProgramDaysProvider` |
| Set active / delete program | Program set above |
| Delete session | `completedSessionsProvider`, `weeklyStatsProvider`, `weeklyVolumeChartProvider`, `recentSessionsProvider` |
| Set user name | `userNameProvider` |
| Body-weight mutation | `invalidateSelf()` on `BodyWeightLogsNotifier` |

---

## 7. ROUTING
`StatefulShellRoute.indexedStack`, **3 tabs**:
| Tab | Root | Children |
|---|---|---|
| Home | `/` | — |
| Routines | `/routines` | `edit/:routineId`, `new`, `:routineId/add-exercise`, `programs/new`, `programs/:programId` |
| History | `/history` | `:sessionId` |

Full-screen overlays: `/workout`, `/exercises`, `/splash`, `/settings`, `/body-weight`, **`/progress-report`**.
Route names via `RouteNames.*` — no magic strings.

---

## 8. PROGRAMS — Key Rules
- Cycle advances on workout completion ONLY (effort-based, not calendar). Rest days auto-skipped.
- `isOverride`: cycle advances only when completing the suggested workout.
- Rest-day detection: `label.toLowerCase() == 'rest'` — NEVER `routineId == null`.
- Templates hardcoded in presentation, not DB. One active program at a time.
- Day rename uses a self-contained dialog widget that owns its `TextEditingController` (disposed in `State.dispose()`), to avoid controller-used-after-dispose crashes.

---

## 9. PROGRESS REPORT — Key Rules
Feature under `lib/features/progress/`. Full-screen route `/progress-report`; entry from Home header + Profile/Settings. Shareable report (weekly default + custom date range) serving trainer (strength) + nutritionist (body comp).
- **Calculations** (pure Domain, in `progress_calculations.dart`): e1RM via **Brzycki** `weight × 36/(37−reps)`, working sets only, reps ≤10. EMA "trend weight" (**alpha 0.15**) with sparse fallback (**<3 logs/week** → straight slope + `isSparse`). Weekly rate-of-change (abs + %). Effective sets/muscle group (warm-ups excluded; **MEV 10 / MRV 20** reference lines). Target adherence % (range = min bound). Session consistency. PRs. Body-comp trends (optional metrics; absent metrics omitted). Phase-aware alerts.
- **Phase-aware color rule** (KPI deltas + alerts): color = clinical meaning, ALWAYS paired with an arrow (↑↓↔). Cutting: ↓=green, ↑=red. Bulking(gaining): ↑=green, ↓=red. Maintaining: ~0=green, drift>0.5%/wk=red. none=neutral.
- **Graceful degradation:** empty optional sections COLLAPSE + show a passive one-line hint. Never render "No Data" boxes.
- Charts are custom `CustomPainter` (no charting package).
- **Pending:** Part 3 — export report to shareable PDF/image (reuse `share_plus` + `path_provider`, RepaintBoundary capture).

---

## 10. UI / THEME RULES
- **Ember** palette: bg0 `#161412`, bg1 `#231F1B`, bg2 `#2E2923`, bg3 `#3D352C`, amber `#E8A83E`, coral `#C75D3A`, green `#6B9E3A`, error `#D44A3A`, txt0 `#EDE6DD`, txt1 `#D4C4B0`, txt2 `#8A8078`, txt3 `#5A5248`.
- **DM Sans** (body) + **DM Mono** (numbers) via `google_fonts`. Never hardcode hex — use `AppTheme.*` / `Theme.of(context).colorScheme.*`.
- Tappable cards use `PressableCard` (scale 0.975, 120ms). Body-part tags via `BodyPartTag`. PR badges = amber tint.
- Modal sheets/dialogs: solid `bg2` background (never transparent), rounded corners.
- Confetti on workout finish via `showConfettiProvider`.
- Superset: amber left bar (3px) + "SUPERSET" badge.
- Reps LEFT / weight RIGHT with permanent unit-aware labels. Warm-up toggle = tapping the set-number box.
- Workout **duration** timer in `workout_status_bar.dart` (counts up total workout time).

---

## 11. REMOVED / DEPRECATED (do not reintroduce)
- **Rest timer entirely removed** — no between-sets countdown, no `rest_timer_panel.dart`, no `restSeconds` column, no `flutter_local_notifications` / `timezone` / `vibration` packages, no related native permissions. (Locked-screen vibration never worked; feature cut.) The workout DURATION timer stays.

---

## 12. CODING STANDARDS
- Null-safe, production-ready Dart. No `print()`.
- Data-source mutations in try-catch → `DatabaseOperationException`. Notifiers handle errors without destroying active session state.
- `if (!context.mounted) return;` after EVERY async gap before using context. Capture theme/context-derived values BEFORE an `await`.
- Dialogs that own a `TextEditingController` must be self-contained widgets disposing it in `State.dispose()` (not disposing right after `await showDialog`).
- No force-unwrap (`x!`) — null-check first. Extract widgets when `build()` > ~80 lines.
- Haptics via `HapticFeedback` (`services.dart`) — this is the built-in API, NOT the removed `vibration` package.

---

## 13. WHAT NOT TO DO
- Do NOT rewrite the whole app. Do NOT add/remove/upgrade packages without approval (STOP and ASK).
- Do NOT change DB schema without a safe migration. Do NOT reference removed `restSeconds`.
- Do NOT use `setState` for app state, BLoC, or GetX. Do NOT import Data from Presentation.
- Do NOT use `state.isLoading` for double-click prevention. Do NOT use `routineId == null` for rest days.
- Do NOT write Freezed 2.x / Riverpod 2.x syntax (see §2.1).

---

## 14. KNOWN ISSUES
- Paste-JSON-Backup dialog in `profile_settings_screen.dart` creates a `TextEditingController` that isn't disposed (minor leak; fix pending).

---

## 15. TASK EXECUTION PROTOCOL
1. Read this file first.
2. State your plan before coding.
3. Show exact file paths; show only changed code with context.
4. Remind the user to run `build_runner` after annotated changes.
5. Verify: `dart analyze` = 0 errors AND `flutter build apk --debug` compiles AND (for logic) tests pass or runtime is confirmed. Do NOT claim success on analyze+build alone for behavior bugs.
6. Respect layer rules, coding standards, edge cases.

---
*End of AGENTS.md — v11.0*