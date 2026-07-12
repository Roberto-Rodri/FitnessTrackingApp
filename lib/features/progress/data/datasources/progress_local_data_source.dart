import 'package:iron_log/core/database/database_helper.dart';
import 'package:iron_log/features/workout/domain/entities/body_weight_log.dart';
import 'package:iron_log/features/workout/domain/entities/exercise.dart';
import 'package:iron_log/features/workout/domain/entities/routine_exercise.dart';
import 'package:iron_log/features/workout/domain/entities/workout_session.dart';
import 'package:iron_log/features/workout/domain/entities/workout_set.dart';
import 'package:iron_log/features/workout/domain/exceptions/workout_exceptions.dart';

class ProgressLocalDataSource {
  final DatabaseHelper dbHelper;

  ProgressLocalDataSource(this.dbHelper);

  Future<List<WorkoutSession>> getSessionsInRange(DateTime start, DateTime end) async {
    try {
      final db = await dbHelper.database;
      final startMs = start.millisecondsSinceEpoch;
      final endMs = end.millisecondsSinceEpoch;
      
      final results = await db.query(
        'workout_sessions',
        where: 'startTimestamp >= ? AND startTimestamp <= ? AND endTimestamp IS NOT NULL',
        whereArgs: [startMs, endMs],
        orderBy: 'startTimestamp ASC',
      );
      return results.map((m) => WorkoutSession.fromJson(m)).toList();
    } catch (e) {
      throw DatabaseOperationException('Failed to get sessions in range: $e');
    }
  }

  Future<List<WorkoutSet>> getSetsForSessions(List<int> sessionIds) async {
    if (sessionIds.isEmpty) return [];
    try {
      final db = await dbHelper.database;
      final placeholders = List.filled(sessionIds.length, '?').join(',');
      final results = await db.query(
        'workout_sets',
        where: 'sessionId IN ($placeholders)',
        whereArgs: sessionIds,
        orderBy: 'id ASC',
      );
      return results.map((m) => WorkoutSet.fromJson(m)).toList();
    } catch (e) {
      throw DatabaseOperationException('Failed to get sets for sessions: $e');
    }
  }

  Future<List<BodyWeightLog>> getBodyWeightLogsInRange(DateTime start, DateTime end) async {
    try {
      final db = await dbHelper.database;
      final startMs = start.millisecondsSinceEpoch;
      final endMs = end.millisecondsSinceEpoch;
      
      final results = await db.query(
        'body_weight_logs',
        where: 'timestamp >= ? AND timestamp <= ?',
        whereArgs: [startMs, endMs],
        orderBy: 'timestamp ASC',
      );
      return results.map((m) {
        // Need to add date parameter for mapping to entity, which takes 'date'.
        // Entity uses json_serializable with ISO8601 strings usually, or ms? Let's assume standard behavior.
        // Actually, the BodyWeightLog entity uses a DateTime `date`.
        // The DB stores `timestamp` in INTEGER.
        final map = Map<String, dynamic>.from(m);
        map['date'] = DateTime.fromMillisecondsSinceEpoch(m['timestamp'] as int).toIso8601String();
        return BodyWeightLog.fromJson(map);
      }).toList();
    } catch (e) {
      throw DatabaseOperationException('Failed to get body weight logs: $e');
    }
  }

  Future<Map<int, Exercise>> getExercisesForSets(List<WorkoutSet> sets) async {
    if (sets.isEmpty) return {};
    final exerciseIds = sets.map((s) => s.exerciseId).toSet().toList();
    try {
      final db = await dbHelper.database;
      final placeholders = List.filled(exerciseIds.length, '?').join(',');
      final results = await db.query(
        'exercises',
        where: 'id IN ($placeholders)',
        whereArgs: exerciseIds,
      );
      final map = <int, Exercise>{};
      for (var row in results) {
        final ex = Exercise.fromJson(row);
        if (ex.id != null) {
          map[ex.id!] = ex;
        }
      }
      return map;
    } catch (e) {
      throw DatabaseOperationException('Failed to get exercises: $e');
    }
  }

  Future<Map<int, RoutineExercise>> getTargetsForSessions(List<int> sessionIds) async {
    if (sessionIds.isEmpty) return {};
    try {
      final db = await dbHelper.database;
      
      final placeholders = List.filled(sessionIds.length, '?').join(',');
      // Find routines for these sessions
      final sessionResults = await db.query(
        'workout_sessions',
        columns: ['routineId'],
        where: 'id IN ($placeholders) AND routineId IS NOT NULL',
        whereArgs: sessionIds,
      );
      
      final routineIds = sessionResults
          .map((r) => r['routineId'] as int?)
          .whereType<int>()
          .toSet()
          .toList();
          
      if (routineIds.isEmpty) return {};
      
      final routinePlaceholders = List.filled(routineIds.length, '?').join(',');
      final crossRefResults = await db.query(
        'routine_exercise_cross_ref',
        where: 'routineId IN ($routinePlaceholders)',
        whereArgs: routineIds,
      );
      
      final map = <int, RoutineExercise>{};
      for (var row in crossRefResults) {
        final re = RoutineExercise.fromJson(row);
        // We'll map by exerciseId for simplicity, assuming one target per exercise per session.
        map[re.exerciseId] = re;
      }
      return map;
    } catch (e) {
      throw DatabaseOperationException('Failed to get targets: $e');
    }
  }
}
