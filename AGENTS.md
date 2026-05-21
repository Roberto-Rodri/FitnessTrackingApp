# AGENTS.md — IronLog Project Rules

> **This file is the single source of truth for this project.**
> Every AI agent working on this codebase MUST read this file before writing, modifying, or suggesting any code.
> If any instruction from the user contradicts this file, ask for clarification — do not silently override these rules.

---

## 1. PROJECT OVERVIEW

**IronLog** is an offline-first fitness tracking app built with Flutter. It targets iOS primarily, with Android emulator used for development. The app follows strict Clean Architecture with Riverpod for state management and SQLite for local persistence.

**Development approach:** AI-assisted ("vibe-coding"). The human is the Lead Architect. The agent writes implementation code following the rules in this document.

---

## 2. TECH STACK

| Component          | Technology                                        |
|--------------------|---------------------------------------------------|
| Framework          | Flutter (Dart >=3.3.0 <4.0.0)                     |
| Architecture       | Clean Architecture (Presentation → Domain → Data)  |
| State Management   | Riverpod 2.x (`riverpod_annotation`, `AsyncNotifier`) |
| Routing            | `go_router` with `StatefulShellRoute`              |
| Database           | `sqflite` (SQLite), version 7                      |
| Models             | `freezed` + `json_serializable`                    |
| Code Generation    | `build_runner`, `riverpod_generator`, `freezed`    |
| Typography         | `google_fonts` (DM Sans + DM Mono)                 |
| Local Prefs        | `shared_preferences` (user name, training phase)   |
| UI/UX              | Material Design 3 (Ember dark theme)               |
| Icons              | `flutter_launcher_icons` (dev dependency)          |

---

## 3. FOLDER STRUCTURE

```
lib/
├── core/
│   ├── database/
│   │   └── database_helper.dart
│   ├── di/
│   │   └── injection.dart
│   ├── routing/
│   │   └── router.dart                   # RouteNames constants + StatefulShellRoute
│   ├── theme/
│   │   └── theme.dart                    # Ember palette + DM Sans/Mono + AppTheme
│   └── widgets/
│       ├── app_shell.dart                # Bottom nav + confetti overlay
│       └── pressable_card.dart           # Universal card press animation
│
├── features/
│   ├── profile/
│   │   ├── data/datasources/user_prefs_local_data_source.dart
│   │   ├── data/repositories/user_prefs_repository_impl.dart
│   │   ├── domain/repositories/user_prefs_repository.dart
│   │   └── presentation/
│   │       ├── controllers/profile_providers.dart  # UserProfileController (name + phase)
│   │       ├── screens/profile_settings_screen.dart
│   │       └── widgets/name_prompt_dialog.dart
│   │
│   ├── program/
│   │   ├── data/datasources/program_local_data_source.dart
│   │   ├── data/repositories/program_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/program.dart
│   │   │   ├── entities/program_day.dart
│   │   │   ├── entities/program_detail.dart
│   │   │   └── repositories/program_repository.dart
│   │   └── presentation/
│   │       ├── controllers/program_providers.dart
│   │       ├── screens/program_edit_screen.dart
│   │       └── widgets/
│   │           ├── cycle_day_card.dart
│   │           ├── cycle_progress_strip.dart
│   │           ├── next_workout_card.dart
│   │           ├── program_card.dart
│   │           └── template_picker.dart
│   │
│   ├── splash/
│   │   └── presentation/screens/splash_screen.dart
│   │
│   └── workout/
│       ├── data/datasources/workout_local_data_source.dart
│       ├── data/repositories/workout_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── body_weight_log.dart
│       │   │   ├── exercise.dart
│       │   │   ├── routine.dart
│       │   │   ├── routine_exercise.dart
│       │   │   ├── routine_exercise_detail.dart
│       │   │   ├── routine_summary.dart
│       │   │   ├── weekly_stats.dart
│       │   │   ├── workout_session.dart
│       │   │   ├── workout_session_summary.dart
│       │   │   └── workout_set.dart
│       │   ├── exceptions/workout_exceptions.dart
│       │   └── repositories/workout_repository.dart
│       └── presentation/
│           ├── controllers/workout_providers.dart
│           ├── screens/
│           │   ├── home_screen.dart
│           │   ├── active_workout_screen.dart
│           │   ├── workout_history_screen.dart
│           │   ├── session_detail_screen.dart
│           │   ├── routine_list_screen.dart
│           │   ├── routine_edit_screen.dart
│           │   ├── exercise_selection_screen.dart
│           │   ├── exercise_library_screen.dart
│           │   └── body_weight_history_screen.dart
│           └── widgets/
│               ├── active_exercise_card.dart
│               ├── body_part_tag.dart
│               ├── body_weight_card.dart
│               ├── carry_forward_notes_card.dart
│               ├── edit_targets_dialog.dart
│               ├── empty_state.dart
│               ├── error_state.dart
│               ├── exercise_form_dialog.dart
│               ├── exercise_swap_sheet.dart
│               ├── log_weight_sheet.dart
│               ├── pr_badge.dart
│               ├── quick_swap_sheet.dart
│               ├── alternative_picker_sheet.dart
│               ├── rest_timer_panel.dart
│               ├── routine_card.dart
│               ├── routine_exercise_tile.dart
│               ├── session_history_card.dart
│               ├── session_notes_field.dart
│               ├── skeleton_loading.dart
│               └── workout_status_bar.dart
│
└── main.dart

assets/
└── icons/
    ├── ironlog_mark.svg
    └── ironlog_icon.png
```

---

## 4. CLEAN ARCHITECTURE RULES (MANDATORY)

### 4.1 Layer Dependencies
```
Presentation  →  Domain  ←  Data
                    ↑
                   Core
```

- **Presentation** may import from **Domain** and **Core** only. NEVER import from **Data**.
- **Data** implements interfaces defined in **Domain**. It may import from **Domain** and **Core**.
- **Domain** imports from **nothing**. Pure Dart only.
- **Core** is shared infrastructure. May be imported by any layer.

### 4.2 Dependency Injection
Infrastructure providers live in `lib/core/di/injection.dart`. This is the ONLY place where Data layer implementations are instantiated.

---

## 5. DATABASE SCHEMA

SQLite via `sqflite`. Database version: **7**. Foreign keys enabled.

### Tables (9 total)

**exercises** — id, name, bodyPart, weightUnit (default 'kg')

**routines** — id, name

**routine_exercise_cross_ref** — routineId (FK CASCADE), exerciseId (FK CASCADE), sequenceOrder, targetSets, targetReps, restSeconds (default 90)

**workout_sessions** — id, startTimestamp, endTimestamp, routineId, routineNameSnapshot, notes (TEXT, nullable)

**workout_sets** — id, sessionId (FK CASCADE), exerciseId (FK CASCADE), weight, reps, rpe, customWeight

**exercise_alternatives** — exerciseId1, exerciseId2 (both FK CASCADE, PK composite, stored with id1 < id2)

**programs** — id, name, cycleLengthDays, isActive (0/1), currentDayIndex

**program_days** — id, programId (FK CASCADE), dayIndex, routineId (FK SET NULL), label

**body_weight_logs** — id (TEXT PK), timestamp (INTEGER), weight (REAL)

### Schema Rules
- Always increment `_databaseVersion` and add `onUpgrade` handler.
- New tables use `ON DELETE CASCADE` (or `SET NULL` for program_days.routineId).

---

## 6. RIVERPOD RULES

### Provider Rules
- Use `@riverpod` annotation. Infrastructure providers: `keepAlive: true` in `injection.dart`.
- Never use `ref.read` in `build()`. Use `ref.watch`.
- After mutations, invalidate affected providers.
- `WorkoutSessionNotifier` uses `_isStarting` flag (not `state.isLoading`) for double-click prevention.
- `startSession()` fetches exercises, best/latest sets, alternatives, and previous session notes internally before completing.
- `UserProfileController` manages both userName and trainingPhase.
- `BodyWeightLogsNotifier` calls `ref.invalidateSelf()` after mutations.

### Provider Invalidation Map

| Mutation | Invalidate |
|----------|-----------|
| Create/edit/delete exercise | `allExercisesProvider`, `bodyPartsProvider`, `routineListProvider` |
| Create/edit/delete routine | `routineListProvider` |
| End session | `completedSessionsProvider`, `weeklyStatsProvider`, `weeklyVolumeChartProvider`, `recentSessionsProvider` |
| End session (from program) | Above + `allProgramsProvider`, `activeProgramProvider`, `currentProgramDayProvider`, `completedProgramDaysProvider` |
| Set active program | `allProgramsProvider`, `activeProgramProvider`, `currentProgramDayProvider`, `completedProgramDaysProvider` |
| Delete program | Same as set active |
| Delete session | `completedSessionsProvider`, `weeklyStatsProvider`, `weeklyVolumeChartProvider`, `recentSessionsProvider` |
| Set user name | `userNameProvider` |
| Body weight mutation | `ref.invalidateSelf()` on `BodyWeightLogsNotifier` |

---

## 7. ROUTING

`StatefulShellRoute.indexedStack` with 3 tabs:

| Tab | Root | Children |
|-----|------|----------|
| Home | `/` | — |
| Routines | `/routines` | `edit/:routineId`, `new`, `:routineId/add-exercise`, `programs/new`, `programs/:programId` |
| History | `/history` | `:sessionId` |

Full-screen overlays: `/workout`, `/exercises`, `/splash`, `/settings`, `/body-weight`

---

## 8. PROGRAMS — Key Rules
- Cycle advances on workout completion ONLY (effort-based, not calendar).
- Rest days auto-skipped when advancing.
- `isOverride` flag: cycle only advances when completing the suggested workout.
- Rest day detection uses `label.toLowerCase() == 'rest'`, NOT `routineId == null`.
- Templates are hardcoded in presentation layer, not in DB.
- Only one active program at a time.

---

## 9. UI / THEME RULES
- **Ember** dark palette: bg0 `#161412`, amber `#E8A83E`, coral `#C75D3A`, error `#D44A3A`
- **DM Sans** (body) + **DM Mono** (numeric data) via `google_fonts`
- Body part tags via `BodyPartTag` widget with per-body-part colors
- Use `Theme.of(context).colorScheme.*` and `AppTheme.*` — never hardcode hex
- PR badges use amber tint styling
- Cards use `PressableCard` wrapper for tap animation
- All tappable cards: scale 0.975 on press, 120ms
- Confetti overlay on workout finish via `showConfettiProvider`
- Training phase badge on HomeScreen avatar (green=gaining, coral=cutting, amber=maintaining)

---

## 10. CODING STANDARDS
- Production-ready, null-safe Dart. No `print()`.
- Data source mutations wrapped in try-catch → `DatabaseOperationException`.
- Notifiers handle errors gracefully — never destroy active session state.
- `if (!context.mounted) return;` after every async gap before using context.
- No force unwrapping `widget.routineId!` — extract and null-check first.
- Modular widgets: extract if `build()` exceeds ~80 lines.
- Route names via `RouteNames.*` constants — no magic strings.
- Haptic feedback at interaction points via `HapticFeedback` from `services.dart`.

---

## 11. KNOWN ISSUES

| # | Issue | Status |
|---|-------|--------|
| 1 | Live duration timer in workout_status_bar.dart is static ('00:00' hardcoded) | 🔴 Needs fix |

---

## 12. WHAT NOT TO DO
- Do NOT rewrite the entire application.
- Do NOT add packages without approval.
- Do NOT change DB schema without migration.
- Do NOT use setState, BLoC, GetX.
- Do NOT import Data from Presentation.
- Do NOT check `state.isLoading` for double-click prevention.
- Do NOT use `routineId == null` to detect rest days — use the label.

---

## 13. TASK EXECUTION PROTOCOL
1. Read this file first.
2. State your plan before coding.
3. Show exact file paths.
4. Show only changed code with context.
5. Remind user to run `build_runner` after annotated changes.
6. Verify against layer rules and coding standards.
7. Consider edge cases.

---

*End of AGENTS.md — v8.0*