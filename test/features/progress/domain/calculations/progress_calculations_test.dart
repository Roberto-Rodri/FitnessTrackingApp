import 'package:flutter_test/flutter_test.dart';
import 'package:iron_log/features/profile/domain/entities/user_profile.dart';
import 'package:iron_log/features/progress/domain/calculations/progress_calculations.dart';
import 'package:iron_log/features/progress/domain/entities/progress_report_data.dart';
import 'package:iron_log/features/workout/domain/entities/body_weight_log.dart';
import 'package:iron_log/features/workout/domain/entities/exercise.dart';
import 'package:iron_log/features/workout/domain/entities/routine_exercise.dart';
import 'package:iron_log/features/workout/domain/entities/workout_session.dart';
import 'package:iron_log/features/workout/domain/entities/workout_set.dart';

void main() {
  group('ProgressCalculations', () {
    final now = DateTime(2026, 7, 1);
    final ex1 = const Exercise(id: 1, name: 'Squat', bodyPart: 'Legs');
    final ex2 = const Exercise(id: 2, name: 'Bench', bodyPart: 'Chest');

    test('calculateE1RMForExercise logic', () {
      final session1 = WorkoutSession(
        id: 1,
        startTimestamp: now.millisecondsSinceEpoch,
        routineNameSnapshot: 'A',
      );
      final set1 = const WorkoutSet(sessionId: 1, exerciseId: 1, weight: 100, reps: 5, isWarmup: false); // Brzycki: 100 * 36/32 = 112.5
      final set2 = const WorkoutSet(sessionId: 1, exerciseId: 1, weight: 105, reps: 5, isWarmup: false); // Brzycki: 105 * 36/32 = 118.125
      final setWarmup = const WorkoutSet(sessionId: 1, exerciseId: 1, weight: 120, reps: 5, isWarmup: true);
      final setHighReps = const WorkoutSet(sessionId: 1, exerciseId: 1, weight: 50, reps: 15, isWarmup: false); // Rep cap

      final result = ProgressCalculations.calculateE1RMForExercise(
        exercise: ex1,
        sets: [set1, set2, setWarmup, setHighReps],
        sessions: [session1],
      );

      expect(result.points.length, 1);
      expect(result.points.first.value, closeTo(118.125, 0.01));
    });

    test('calculateWeightTrend EMA vs Sparse', () {
      final start = DateTime(2026, 7, 1);
      final end = DateTime(2026, 7, 7); // 1 week
      
      // Sparse (2 logs)
      final logsSparse = [
        BodyWeightLog(id: '1', date: start, weight: 80),
        BodyWeightLog(id: '2', date: end, weight: 81),
      ];
      final sparseResult = ProgressCalculations.calculateWeightTrend(logsSparse, start, end);
      expect(sparseResult.isSparse, true);
      expect(sparseResult.emaAlpha, isNull);
      expect(sparseResult.trendPoints.length, 2);
      
      // Dense (4 logs)
      final logsDense = [
        BodyWeightLog(id: '1', date: start, weight: 80),
        BodyWeightLog(id: '2', date: start.add(const Duration(days: 2)), weight: 80.5),
        BodyWeightLog(id: '3', date: start.add(const Duration(days: 4)), weight: 81),
        BodyWeightLog(id: '4', date: end, weight: 81.5),
      ];
      final denseResult = ProgressCalculations.calculateWeightTrend(logsDense, start, end);
      expect(denseResult.isSparse, false);
      expect(denseResult.emaAlpha, ProgressCalculations.emaAlpha);
      expect(denseResult.trendPoints.length, 4);
    });

    test('calculateRateOfChange normalizes to 7 days', () {
      // 14 days, from 80 to 82. Should be 1/week.
      final trendData = WeightTrendData(
        isSparse: true,
        emaAlpha: null,
        rawPoints: [
          DataPoint(date: DateTime(2026, 7, 1), value: 80),
          DataPoint(date: DateTime(2026, 7, 15), value: 82),
        ],
        trendPoints: [
          DataPoint(date: DateTime(2026, 7, 1), value: 80),
          DataPoint(date: DateTime(2026, 7, 15), value: 82),
        ],
      );

      final roc = ProgressCalculations.calculateRateOfChange(trendData);
      expect(roc.absPerWeek, closeTo(1.0, 0.01));
      expect(roc.pctPerWeek, closeTo(1.25, 0.01)); // (2/80)/2 * 100
    });

    test('calculateEffectiveSets counts only non-warmup', () {
      final sets = [
        const WorkoutSet(sessionId: 1, exerciseId: 1, weight: 100, reps: 5, isWarmup: false),
        const WorkoutSet(sessionId: 1, exerciseId: 1, weight: 100, reps: 5, isWarmup: false),
        const WorkoutSet(sessionId: 1, exerciseId: 1, weight: 100, reps: 5, isWarmup: true),
        const WorkoutSet(sessionId: 1, exerciseId: 2, weight: 50, reps: 10, isWarmup: false),
      ];
      final exMap = {1: ex1, 2: ex2};
      
      final result = ProgressCalculations.calculateEffectiveSets(sets, exMap);
      expect(result.length, 2);
      final legs = result.firstWhere((e) => e.bodyPart == 'Legs');
      expect(legs.count, 2);
      final chest = result.firstWhere((e) => e.bodyPart == 'Chest');
      expect(chest.count, 1);
    });

    test('calculateAdherence checks min reps', () {
      final sets = [
        const WorkoutSet(sessionId: 1, exerciseId: 1, weight: 100, reps: 8, isWarmup: false), // Hit target
        const WorkoutSet(sessionId: 1, exerciseId: 1, weight: 100, reps: 7, isWarmup: false), // Missed target
        const WorkoutSet(sessionId: 1, exerciseId: 2, weight: 50, reps: 10, isWarmup: false), // Hit target
      ];
      final targets = {
        1: const RoutineExercise(routineId: 1, exerciseId: 1, sequenceOrder: 1, targetSets: 3, targetReps: '8-12'),
        2: const RoutineExercise(routineId: 1, exerciseId: 2, sequenceOrder: 2, targetSets: 3, targetReps: '10'),
      };

      final adherence = ProgressCalculations.calculateAdherence(sets, targets);
      expect(adherence.setsTotal, 3);
      expect(adherence.setsHit, 2);
      expect(adherence.pct, closeTo(66.66, 0.1));
    });

    test('generatePhaseAlerts for cutting', () {
      final roc = const RateOfChange(absPerWeek: -2.0, pctPerWeek: -2.0); // Dropping 2% per week (too fast)
      final e1rmData = [
        E1rmSeries(
          exerciseName: 'Squat', 
          points: [
            DataPoint(date: now, value: 100),
            DataPoint(date: now.add(const Duration(days: 7)), value: 90), // Dropped 10%
          ],
        )
      ];

      final alerts = ProgressCalculations.generatePhaseAlerts(
        phase: TrainingPhase.cutting,
        roc: roc,
        e1rmData: e1rmData,
      );

      expect(alerts.any((a) => a.text.contains('Weight dropping faster')), true);
      expect(alerts.any((a) => a.text.contains('Strength collapse')), true);
    });
  });
}
