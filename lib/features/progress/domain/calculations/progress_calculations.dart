import 'dart:math';

import 'package:iron_log/features/profile/domain/entities/user_profile.dart';
import 'package:iron_log/features/progress/domain/entities/progress_report_data.dart';
import 'package:iron_log/features/workout/domain/entities/body_weight_log.dart';
import 'package:iron_log/features/workout/domain/entities/exercise.dart';
import 'package:iron_log/features/workout/domain/entities/routine_exercise.dart';
import 'package:iron_log/features/workout/domain/entities/workout_session.dart';
import 'package:iron_log/features/workout/domain/entities/workout_set.dart';

class ProgressCalculations {
  static const int brzyckiRepCap = 10;
  static const double emaAlpha = 0.15;
  static const int sparseLogsThresholdPerWeek = 3;

  /// 1. e1RM — Brzycki formula
  /// e1RM = weight × (36 / (37 − reps))
  static double _calculateBrzycki(double weight, int reps) {
    if (reps > brzyckiRepCap) return 0; // Exclude high reps for accuracy
    if (reps < 1) return 0;
    return weight * (36 / (37 - reps));
  }

  /// Calculates the best e1RM per session date for a given exercise.
  static E1rmSeries calculateE1RMForExercise({
    required Exercise exercise,
    required List<WorkoutSet> sets,
    required List<WorkoutSession> sessions,
  }) {
    final sessionMap = {for (var s in sessions) s.id: s};
    final bestE1rmPerDate = <DateTime, double>{};

    for (final set in sets) {
      if (set.isWarmup || set.reps > brzyckiRepCap || set.reps < 1) continue;
      
      final session = sessionMap[set.sessionId];
      if (session == null) continue;

      // Group by exact day
      final date = DateTime.fromMillisecondsSinceEpoch(session.startTimestamp);
      final day = DateTime(date.year, date.month, date.day);

      final e1rm = _calculateBrzycki(set.weight, set.reps);
      if (e1rm > 0) {
        if (!bestE1rmPerDate.containsKey(day) || bestE1rmPerDate[day]! < e1rm) {
          bestE1rmPerDate[day] = e1rm;
        }
      }
    }

    final sortedDates = bestE1rmPerDate.keys.toList()..sort();
    final points = sortedDates.map((d) => DataPoint(date: d, value: bestE1rmPerDate[d]!)).toList();

    return E1rmSeries(
      exerciseName: exercise.name,
      points: points,
    );
  }

  /// 2. Weight trend (EMA with sparse fallback)
  static WeightTrendData calculateWeightTrend(List<BodyWeightLog> logs, DateTime startDate, DateTime endDate) {
    if (logs.isEmpty) {
      return const WeightTrendData(isSparse: true, rawPoints: [], trendPoints: [], emaAlpha: null);
    }

    final sortedLogs = List<BodyWeightLog>.from(logs)..sort((a, b) => a.date.compareTo(b.date));
    final rawPoints = sortedLogs.map((l) => DataPoint(date: l.date, value: l.weight)).toList();

    final daysInRange = endDate.difference(startDate).inDays;
    final weeksInRange = max(1.0, daysInRange / 7.0);
    final density = logs.length / weeksInRange;

    if (density >= sparseLogsThresholdPerWeek) {
      // Calculate EMA
      final trendPoints = <DataPoint>[];
      double currentEma = rawPoints.first.value;
      trendPoints.add(DataPoint(date: rawPoints.first.date, value: currentEma));

      for (int i = 1; i < rawPoints.length; i++) {
        final pt = rawPoints[i];
        currentEma = (pt.value * emaAlpha) + (currentEma * (1 - emaAlpha));
        trendPoints.add(DataPoint(date: pt.date, value: currentEma));
      }

      return WeightTrendData(
        isSparse: false,
        rawPoints: rawPoints,
        trendPoints: trendPoints,
        emaAlpha: emaAlpha,
      );
    } else {
      // Sparse: return simple two-point slope if >= 2 points, else just the raw points
      List<DataPoint> trendPoints = [];
      if (rawPoints.length >= 2) {
         trendPoints = [rawPoints.first, rawPoints.last];
      }
      return WeightTrendData(
        isSparse: true,
        rawPoints: rawPoints,
        trendPoints: trendPoints,
        emaAlpha: null,
      );
    }
  }

  /// 3. Weekly rate of change (RoC)
  static RateOfChange calculateRateOfChange(WeightTrendData trendData) {
    final points = trendData.isSparse ? trendData.rawPoints : trendData.trendPoints;
    if (points.length < 2) {
      return const RateOfChange(absPerWeek: 0, pctPerWeek: 0);
    }

    final first = points.first;
    final last = points.last;

    final days = max(1, last.date.difference(first.date).inDays);
    final weeks = days / 7.0;

    final absDiff = last.value - first.value;
    final absPerWeek = absDiff / weeks;

    final pctDiff = (last.value - first.value) / first.value;
    final pctPerWeek = (pctDiff / weeks) * 100.0;

    return RateOfChange(absPerWeek: absPerWeek, pctPerWeek: pctPerWeek);
  }

  /// 4. Effective sets per muscle group
  static List<EffectiveSetCount> calculateEffectiveSets(
      List<WorkoutSet> sets, Map<int, Exercise> exerciseMap) {
    final counts = <String, int>{};

    for (final set in sets) {
      if (set.isWarmup) continue;
      final ex = exerciseMap[set.exerciseId];
      if (ex != null) {
        counts[ex.bodyPart] = (counts[ex.bodyPart] ?? 0) + 1;
      }
    }

    final list = counts.entries
        .map((e) => EffectiveSetCount(bodyPart: e.key, count: e.value))
        .toList();
    list.sort((a, b) => b.count.compareTo(a.count)); // Descending
    return list;
  }

  /// 5. Target adherence %
  static AdherenceData calculateAdherence(
      List<WorkoutSet> sets, Map<int, RoutineExercise> targetMap) {
    int setsTotal = 0;
    int setsHit = 0;

    for (final set in sets) {
      if (set.isWarmup) continue;
      // We assume targetMap key is exerciseId. 
      // If a session has multiple routines, this might be ambiguous, 
      // but for this context we map by exerciseId within the session's routine.
      final target = targetMap[set.exerciseId];
      if (target != null) {
        setsTotal++;
        final minTarget = _parseMinReps(target.targetReps);
        if (minTarget != null && set.reps >= minTarget) {
          setsHit++;
        }
      }
    }

    final pct = setsTotal == 0 ? 0.0 : (setsHit / setsTotal) * 100.0;
    return AdherenceData(pct: pct, setsHit: setsHit, setsTotal: setsTotal);
  }

  static int? _parseMinReps(String targetReps) {
    final parts = targetReps.split('-');
    if (parts.isNotEmpty) {
      return int.tryParse(parts.first.trim());
    }
    return null;
  }

  /// 9. Phase-aware alerts (red flags)
  static List<AlertData> generatePhaseAlerts({
    required TrainingPhase phase,
    required RateOfChange roc,
    required List<E1rmSeries> e1rmData,
  }) {
    final alerts = <AlertData>[];

    // Determine if E1RM is dropping. 
    // We'll average the start-to-end percent change across available tracked exercises.
    double avgE1rmChangePct = 0;
    int e1rmCount = 0;
    for (final series in e1rmData) {
      if (series.points.length >= 2) {
        final first = series.points.first.value;
        final last = series.points.last.value;
        avgE1rmChangePct += ((last - first) / first) * 100.0;
        e1rmCount++;
      }
    }
    if (e1rmCount > 0) {
      avgE1rmChangePct /= e1rmCount;
    }

    switch (phase) {
      case TrainingPhase.cutting:
        if (roc.pctPerWeek < -1.5) {
          alerts.add(const AlertData(
              severity: AlertSeverity.warning,
              text: 'Weight dropping faster than optimal (>1.5%/wk) — muscle-loss risk.'));
        }
        if (avgE1rmChangePct < -5.0) {
          alerts.add(const AlertData(
              severity: AlertSeverity.warning,
              text: 'Strength collapse — deficit may be too aggressive (e1RM dropped > 5%).'));
        }
        if (roc.pctPerWeek <= -0.5 && roc.pctPerWeek >= -1.5 && avgE1rmChangePct >= -2.0) {
          alerts.add(const AlertData(
              severity: AlertSeverity.good,
              text: 'Healthy cut: Weight dropping at good rate and strength is stable.'));
        }
        break;
      case TrainingPhase.gaining:
        if (roc.pctPerWeek > 1.0) {
          alerts.add(const AlertData(
              severity: AlertSeverity.warning,
              text: 'Gaining faster than optimal (>1.0%/wk) — excess fat gain risk.'));
        }
        if (roc.pctPerWeek > 0.2 && avgE1rmChangePct <= 0) {
          alerts.add(const AlertData(
              severity: AlertSeverity.warning,
              text: 'Strength stalled during a bulk — review recovery/sleep/volume.'));
        }
        if (roc.pctPerWeek >= 0.25 && roc.pctPerWeek <= 0.5 && avgE1rmChangePct > 1.0) {
          alerts.add(const AlertData(
              severity: AlertSeverity.good,
              text: 'Healthy bulk: Weight gaining steadily and strength is rising.'));
        }
        break;
      case TrainingPhase.maintaining:
        if (roc.pctPerWeek > 0.5 || roc.pctPerWeek < -0.5) {
          alerts.add(const AlertData(
              severity: AlertSeverity.warning,
              text: 'Weight drifting outside maintenance range (>0.5%/wk).'));
        }
        if (roc.pctPerWeek >= -0.5 && roc.pctPerWeek <= 0.5) {
          alerts.add(const AlertData(
              severity: AlertSeverity.good,
              text: 'Weight is holding steady in maintenance range.'));
        }
        break;
      case TrainingPhase.none:
        // No specific weight alerts, but strength alerts
        if (avgE1rmChangePct < -5.0) {
          alerts.add(const AlertData(
              severity: AlertSeverity.warning,
              text: 'Strength has decreased noticeably (e1RM dropped > 5%).'));
        } else if (avgE1rmChangePct > 5.0) {
          alerts.add(const AlertData(
              severity: AlertSeverity.good,
              text: 'Strength has increased nicely!'));
        }
        break;
    }

    return alerts;
  }
}
