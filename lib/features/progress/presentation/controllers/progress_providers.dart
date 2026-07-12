import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:iron_log/core/di/injection.dart';
import 'package:iron_log/features/profile/domain/entities/user_profile.dart';
import 'package:iron_log/features/profile/presentation/controllers/profile_providers.dart';
import 'package:iron_log/features/progress/domain/calculations/progress_calculations.dart';
import 'package:iron_log/features/progress/domain/entities/progress_report_data.dart';
part 'progress_providers.g.dart';

@riverpod
Future<ProgressReportData> progressReport(Ref ref, DateTime startDate, DateTime endDate) async {
  final repository = ref.watch(progressRepositoryProvider);
  final workoutRepository = ref.watch(workoutRepositoryProvider);
  
  // 1. Fetch user phase
  final userProfile = ref.watch(userProfileControllerProvider);
  final currentPhase = userProfile.value?.phase ?? TrainingPhase.none;

  // 2. Fetch raw data
  final sessions = await repository.getSessionsInRange(startDate, endDate);
  final sessionIds = sessions.map((s) => s.id!).toList();
  
  final sets = await repository.getSetsForSessions(sessionIds);
  final exercises = await repository.getExercisesForSets(sets);
  final targets = await repository.getTargetsForSessions(sessionIds);
  final bodyWeightLogs = await repository.getBodyWeightLogsInRange(startDate, endDate);

  // 3. Compute top 2-3 compound exercises (by frequency of sets in range)
  final exerciseSetCounts = <int, int>{};
  for (var s in sets) {
    if (!s.isWarmup) {
      exerciseSetCounts[s.exerciseId] = (exerciseSetCounts[s.exerciseId] ?? 0) + 1;
    }
  }
  final sortedExercises = exerciseSetCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final topExerciseIds = sortedExercises.take(3).map((e) => e.key).toList();

  // 4. Calculations
  final e1rmData = <E1rmSeries>[];
  for (final exId in topExerciseIds) {
    final ex = exercises[exId];
    if (ex != null) {
      final exSets = sets.where((s) => s.exerciseId == exId).toList();
      final series = ProgressCalculations.calculateE1RMForExercise(
        exercise: ex,
        sets: exSets,
        sessions: sessions,
      );
      if (series.points.isNotEmpty) {
        e1rmData.add(series);
      }
    }
  }

  final weightTrend = ProgressCalculations.calculateWeightTrend(bodyWeightLogs, startDate, endDate);
  final roc = ProgressCalculations.calculateRateOfChange(weightTrend);
  final effectiveSets = ProgressCalculations.calculateEffectiveSets(sets, exercises);
  final adherence = ProgressCalculations.calculateAdherence(sets, targets);

  // 5. Session consistency
  final completed = sessions.length;
  // Without a hard program schedule, we just report completed for now.
  final consistency = ConsistencyData(completed: completed);

  // 6. PRs
  final prs = <PR>[];
  for (var set in sets) {
    if (set.isWarmup) continue;
    final isPR = await workoutRepository.isPersonalRecord(set.exerciseId, set.weight, set.reps, set.id!);
    if (isPR) {
      final ex = exercises[set.exerciseId];
      if (ex != null) {
        final session = sessions.firstWhere((s) => s.id == set.sessionId);
        final date = DateTime.fromMillisecondsSinceEpoch(session.startTimestamp);
        prs.add(PR(exerciseName: ex.name, weight: set.weight, reps: set.reps, date: date));
      }
    }
  }

  // 7. Body composition trends
  final bodyCompMap = <String, List<DataPoint>>{
    'bodyFatPercentage': [],
    'muscleMass': [],
    'waist': [],
    'chest': [],
    'arms': [],
  };

  for (final log in bodyWeightLogs) {
    if (log.bodyFatPercentage != null) bodyCompMap['bodyFatPercentage']!.add(DataPoint(date: log.date, value: log.bodyFatPercentage!));
    if (log.muscleMass != null) bodyCompMap['muscleMass']!.add(DataPoint(date: log.date, value: log.muscleMass!));
    if (log.waist != null) bodyCompMap['waist']!.add(DataPoint(date: log.date, value: log.waist!));
    if (log.chest != null) bodyCompMap['chest']!.add(DataPoint(date: log.date, value: log.chest!));
    if (log.arms != null) bodyCompMap['arms']!.add(DataPoint(date: log.date, value: log.arms!));
  }

  final bodyComposition = <BodyCompositionSeries>[];
  for (final entry in bodyCompMap.entries) {
    if (entry.value.isNotEmpty) {
      bodyComposition.add(BodyCompositionSeries(metricName: entry.key, points: entry.value));
    }
  }

  // 8. Phase-aware alerts
  final alerts = ProgressCalculations.generatePhaseAlerts(
    phase: currentPhase,
    roc: roc,
    e1rmData: e1rmData,
  );

  // 9. Session notes
  final notes = sessions
    .where((s) => s.notes != null && s.notes!.trim().isNotEmpty)
    .map((s) => s.notes!)
    .toList();

  return ProgressReportData(
    startDate: startDate,
    endDate: endDate,
    phase: currentPhase,
    e1rmData: e1rmData,
    weightTrend: weightTrend,
    weeklyRateOfChange: roc,
    effectiveSets: effectiveSets,
    adherence: adherence,
    consistency: consistency,
    prs: prs,
    bodyComposition: bodyComposition,
    alerts: alerts,
    sessionNotes: notes,
  );
}
