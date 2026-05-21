import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/workout_set.dart';
import '../../domain/exceptions/workout_exceptions.dart';
import '../../domain/entities/routine_exercise_detail.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout_session_summary.dart';
import '../../domain/entities/routine_summary.dart';
import '../../domain/entities/weekly_stats.dart';
import '../../../program/presentation/controllers/program_providers.dart';

part 'workout_providers.g.dart';

final useRoutineLatestProvider = StateProvider<bool>((ref) => true);

class ActiveWorkoutState {
  final int? sessionId;
  final int? routineId;
  final int? startTimestamp; // ms since epoch, set when session begins
  final List<WorkoutSet> sets;
  final List<RoutineExerciseDetail> activeExercises;
  final Map<int, Map<String, dynamic>> bestSets;
  final Map<int, Map<String, dynamic>> latestSetsGlobal;
  final Map<int, Map<String, dynamic>> latestSetsRoutine;
  final Map<int, List<Exercise>> alternatives;
  final int? lastLoggedRestSeconds;
  final int loggedSetCount;
  final int? lastPRSetId;
  final int? programId;
  final int? programDayIndex;
  final bool isOverride;
  final String notes;
  final String? previousSessionNotes;
  final Map<int, List<WorkoutSet>> previousSetsByExercise;

  const ActiveWorkoutState({
    this.sessionId,
    this.routineId,
    this.startTimestamp,
    this.sets = const [],
    this.activeExercises = const [],
    this.bestSets = const {},
    this.latestSetsGlobal = const {},
    this.latestSetsRoutine = const {},
    this.alternatives = const {},
    this.lastLoggedRestSeconds,
    this.loggedSetCount = 0,
    this.lastPRSetId,
    this.programId,
    this.programDayIndex,
    this.isOverride = false,
    this.notes = '',
    this.previousSessionNotes,
    this.previousSetsByExercise = const {},
  });

  ActiveWorkoutState copyWith({
    int? sessionId,
    int? routineId,
    int? startTimestamp,
    List<WorkoutSet>? sets,
    List<RoutineExerciseDetail>? activeExercises,
    Map<int, Map<String, dynamic>>? bestSets,
    Map<int, Map<String, dynamic>>? latestSetsGlobal,
    Map<int, Map<String, dynamic>>? latestSetsRoutine,
    Map<int, List<Exercise>>? alternatives,
    int? lastLoggedRestSeconds,
    int? loggedSetCount,
    int? lastPRSetId,
    int? programId,
    int? programDayIndex,
    bool? isOverride,
    String? notes,
    String? previousSessionNotes,
    Map<int, List<WorkoutSet>>? previousSetsByExercise,
  }) {
    return ActiveWorkoutState(
      sessionId: sessionId ?? this.sessionId,
      routineId: routineId ?? this.routineId,
      startTimestamp: startTimestamp ?? this.startTimestamp,
      sets: sets ?? this.sets,
      activeExercises: activeExercises ?? this.activeExercises,
      bestSets: bestSets ?? this.bestSets,
      latestSetsGlobal: latestSetsGlobal ?? this.latestSetsGlobal,
      latestSetsRoutine: latestSetsRoutine ?? this.latestSetsRoutine,
      alternatives: alternatives ?? this.alternatives,
      lastLoggedRestSeconds: lastLoggedRestSeconds ?? this.lastLoggedRestSeconds,
      loggedSetCount: loggedSetCount ?? this.loggedSetCount,
      lastPRSetId: lastPRSetId,
      programId: programId ?? this.programId,
      programDayIndex: programDayIndex ?? this.programDayIndex,
      isOverride: isOverride ?? this.isOverride,
      notes: notes ?? this.notes,
      previousSessionNotes: previousSessionNotes ?? this.previousSessionNotes,
      previousSetsByExercise: previousSetsByExercise ?? this.previousSetsByExercise,
    );
  }
}

// Added sessionPRCount
@riverpod
Future<int> sessionPRCount(SessionPRCountRef ref, int sessionId) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.countPRsInSession(sessionId);
}

@riverpod
Future<List<WorkoutSessionSummary>> completedSessions(CompletedSessionsRef ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getCompletedSessions();
}

enum HistoryFilter { all, thisWeek, thisMonth }

final historyFilterProvider = StateProvider<HistoryFilter>((ref) => HistoryFilter.all);

@riverpod
Future<List<WorkoutSessionSummary>> filteredSessions(FilteredSessionsRef ref) async {
  final filter = ref.watch(historyFilterProvider);
  final allSessions = await ref.watch(completedSessionsProvider.future);
  
  if (filter == HistoryFilter.all) return allSessions;
  
  final now = DateTime.now();
  return allSessions.where((session) {
    final sessionDate = DateTime.fromMillisecondsSinceEpoch(
      session.session.startTimestamp,
    );
    switch (filter) {
      case HistoryFilter.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);
        return sessionDate.isAfter(startOfWeek);
      case HistoryFilter.thisMonth:
        return sessionDate.year == now.year && sessionDate.month == now.month;
      case HistoryFilter.all:
        return true;
    }
  }).toList();
}

@riverpod
Future<List<WorkoutSet>> sessionSets(SessionSetsRef ref, int sessionId) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getSetsForSession(sessionId);
}

@riverpod
Future<Map<int, Exercise>> sessionExerciseInfo(SessionExerciseInfoRef ref, int sessionId) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getExerciseInfoForSession(sessionId);
}

@riverpod
Future<List<Exercise>> allExercises(AllExercisesRef ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getExercises();
}

@riverpod
Future<List<Exercise>> exerciseAlternatives(ExerciseAlternativesRef ref, int exerciseId) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getAlternativesForExercise(exerciseId);
}

@riverpod
Future<List<RoutineSummary>> routineList(RoutineListRef ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getRoutinesWithInfo();
}

@riverpod
Future<List<RoutineExerciseDetail>> routineExercises(RoutineExercisesRef ref, int routineId) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getExercisesForRoutine(routineId);
}

@riverpod
Future<List<String>> bodyParts(BodyPartsRef ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getDistinctBodyParts();
}

@riverpod
Future<WeeklyStats> weeklyStats(WeeklyStatsRef ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getWeeklyStats();
}

@riverpod
Future<List<double>> weeklyVolumeChart(WeeklyVolumeChartRef ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getWeeklyVolumeChart();
}

@riverpod
Future<List<WorkoutSessionSummary>> recentSessions(RecentSessionsRef ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getRecentSessions(3);
}

@riverpod
Future<RoutineSummary?> lastRoutine(LastRoutineRef ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getLastUsedRoutine();
}

final showConfettiProvider = StateProvider<bool>((ref) => false);

@riverpod
Future<WorkoutSessionSummary?> previousSession(PreviousSessionRef ref, int routineId, int currentSessionId) async {
  final repository = ref.watch(workoutRepositoryProvider);
  final session = await repository.getPreviousSession(routineId, currentSessionId);
  if (session == null) return null;
  
  final sets = await repository.getSetsForSession(session.id!);
  
  int totalSets = sets.length;
  double totalVolume = 0.0;
  for (final s in sets) {
    if (!s.isWarmup) {
      totalVolume += s.weight * s.reps;
    }
  }

  return WorkoutSessionSummary(
    session: session,
    totalSets: totalSets,
    totalVolume: totalVolume,
  );
}

@Riverpod(keepAlive: true)
class WorkoutSessionNotifier extends _$WorkoutSessionNotifier {
  bool _isStarting = false;

  @override
  Future<ActiveWorkoutState> build() async {
    return const ActiveWorkoutState();
  }

  Future<void> startSession(
    int routineId, 
    String name, {
    int? programId,
    int? programDayIndex,
    bool isOverride = false,
  }) async {
    if (_isStarting) return; // Prevent double-clicks
    _isStarting = true;
    
    state = const AsyncLoading();
    try {
      final repository = ref.read(workoutRepositoryProvider);
      
      // Step 1: Create the session in DB
      final sessionId = await repository.startSession(routineId, name);
      
      // Step 2: Fetch exercises for this routine BEFORE setting state
      final exercises = await repository.getExercisesForRoutine(routineId);
      final exerciseIds = exercises.map((e) => e.exerciseId).toList();
      
      final bestSets = await repository.getBestSetsForExercises(exerciseIds);
      final latestSetsGlobal = await repository.getLatestSetsForExercises(exerciseIds);
      final latestSetsRoutine = await repository.getLatestSetsForExercisesInRoutine(exerciseIds, routineId);
      final alternatives = await repository.getAlternativesForExercises(exerciseIds);
      
      final completedSessions = await repository.getCompletedSessions();
      final previousSession = completedSessions.cast<WorkoutSessionSummary?>().firstWhere(
        (s) => s?.session.routineId == routineId,
        orElse: () => null,
      );
      final previousSessionNotes = previousSession?.session.notes;
      
      final previousSetsRaw = await repository.getPreviousSetsForRoutine(routineId);
      final Map<int, List<WorkoutSet>> previousSetsByExercise = {};
      for (final s in previousSetsRaw) {
        previousSetsByExercise.putIfAbsent(s.exerciseId, () => []).add(s);
      }

      // Step 3: Set state with EVERYTHING ready
      state = AsyncData(ActiveWorkoutState(
        sessionId: sessionId,
        routineId: routineId,
        startTimestamp: DateTime.now().millisecondsSinceEpoch,
        sets: [],
        activeExercises: exercises,
        bestSets: bestSets,
        latestSetsGlobal: latestSetsGlobal,
        latestSetsRoutine: latestSetsRoutine,
        alternatives: alternatives,
        programId: programId,
        programDayIndex: programDayIndex,
        isOverride: isOverride,
        previousSessionNotes: previousSessionNotes,
        previousSetsByExercise: previousSetsByExercise,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    } finally {
      _isStarting = false;
    }
  }

  Future<void> logNewSet(WorkoutSet set) async {
    final currentState = state.value;
    if (currentState == null || currentState.sessionId == null) {
      throw NoActiveSessionException('Cannot log set — no active session');
    }

    final setWithSession = set.copyWith(sessionId: currentState.sessionId!);

    // Optimistically updating UI requires the DB ID first
    try {
      final repository = ref.read(workoutRepositoryProvider);
      final id = await repository.logSet(setWithSession);
      
      final setWithId = setWithSession.copyWith(id: id);
      final newSets = [...currentState.sets, setWithId];

      final exerciseDetail = currentState.activeExercises.firstWhere(
        (e) => e.exerciseId == setWithSession.exerciseId,
      );

      bool isPR = false;
      if (!setWithSession.isWarmup && (exerciseDetail.weightUnit == 'kg' || exerciseDetail.weightUnit == 'lbs')) {
        isPR = await repository.isPersonalRecord(setWithSession.exerciseId, setWithSession.weight, setWithSession.reps, id);
      }

      state = AsyncData(currentState.copyWith(
        sets: newSets,
        lastLoggedRestSeconds: exerciseDetail.restSeconds,
        loggedSetCount: currentState.loggedSetCount + 1,
        lastPRSetId: isPR ? id : null, // Set PR ID if it's a PR, or null if it's not.
      ));
    } catch (e) {
      // Revert on failure to the captured previous state (do NOT use AsyncError)
      state = AsyncData(currentState);
    }
  }

  Future<int?> endSession() async {
    final currentState = state.value;
    if (currentState == null || currentState.sessionId == null) return null;

    try {
      final repository = ref.read(workoutRepositoryProvider);
      if (currentState.notes.isNotEmpty) {
        await repository.updateSessionNotes(currentState.sessionId!, currentState.notes);
      }
      await repository.endSession(currentState.sessionId!);
      state = const AsyncData(ActiveWorkoutState());
      
      ref.invalidate(completedSessionsProvider);
      ref.invalidate(weeklyStatsProvider);
      ref.invalidate(weeklyVolumeChartProvider);
      ref.invalidate(recentSessionsProvider);

      if (currentState.programId != null && !currentState.isOverride) {
        final programRepo = ref.read(programRepositoryProvider);
        await programRepo.advanceCycleDay(currentState.programId!);
        
        ref.invalidate(allProgramsProvider);
        ref.invalidate(activeProgramProvider);
        ref.invalidate(currentProgramDayProvider);
      }
      return currentState.sessionId;
    } catch (e) {
      // Revert to current state on failure
      state = AsyncData(currentState);
      return null;
    }
  }

  Future<void> toggleWarmup(int setId) async {
    final currentState = state.value;
    if (currentState == null) return;

    final setIndex = currentState.sets.indexWhere((s) => s.id == setId);
    if (setIndex == -1) return;

    final targetSet = currentState.sets[setIndex];
    final newIsWarmup = !targetSet.isWarmup;

    try {
      final repository = ref.read(workoutRepositoryProvider);
      await repository.toggleSetWarmup(setId, newIsWarmup);

      final updatedSets = List<WorkoutSet>.from(currentState.sets);
      updatedSets[setIndex] = targetSet.copyWith(isWarmup: newIsWarmup);

      state = AsyncData(currentState.copyWith(sets: updatedSets));
    } catch (e) {
      // Do nothing on failure, maybe log
    }
  }

  void updateNotes(String text) {
    final currentState = state.value;
    if (currentState == null) return;
    state = AsyncData(currentState.copyWith(notes: text));
  }

  Future<void> swapExercise(int originalExerciseId, Exercise newExercise) async {
    final currentState = state.value;
    if (currentState == null) return;
    
    final updatedExercises = currentState.activeExercises.map((e) {
      if (e.exerciseId == originalExerciseId) {
        return e.copyWith(
          exerciseId: newExercise.id!,
          exerciseName: newExercise.name,
          bodyPart: newExercise.bodyPart,
        );
      }
      return e;
    }).toList();
    
    final newExerciseId = newExercise.id!;
    final repository = ref.read(workoutRepositoryProvider);
    
    // Fetch reference data for the new exercise
    final newBest = await repository.getBestSetsForExercises([newExerciseId]);
    final newLatestGlobal = await repository.getLatestSetsForExercises([newExerciseId]);
    final newLatestRoutine = currentState.routineId != null 
        ? await repository.getLatestSetsForExercisesInRoutine([newExerciseId], currentState.routineId!)
        : <int, Map<String, dynamic>>{};
    final newAlternatives = await repository.getAlternativesForExercises([newExerciseId]);

    final updatedBestSets = Map<int, Map<String, dynamic>>.from(currentState.bestSets)..addAll(newBest);
    final updatedLatestGlobal = Map<int, Map<String, dynamic>>.from(currentState.latestSetsGlobal)..addAll(newLatestGlobal);
    final updatedLatestRoutine = Map<int, Map<String, dynamic>>.from(currentState.latestSetsRoutine)..addAll(newLatestRoutine);
    final updatedAlternatives = Map<int, List<Exercise>>.from(currentState.alternatives)..addAll(newAlternatives);

    state = AsyncData(currentState.copyWith(
      activeExercises: updatedExercises,
      bestSets: updatedBestSets,
      latestSetsGlobal: updatedLatestGlobal,
      latestSetsRoutine: updatedLatestRoutine,
      alternatives: updatedAlternatives,
    ));
  }
}
