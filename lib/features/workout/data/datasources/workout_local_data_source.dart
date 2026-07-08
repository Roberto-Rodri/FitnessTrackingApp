import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/routine.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/entities/workout_set.dart';
import '../../domain/entities/routine_exercise_detail.dart';
import '../../domain/entities/workout_session_summary.dart';
import '../../domain/entities/weekly_stats.dart';
import '../../domain/exceptions/workout_exceptions.dart';
import '../../domain/entities/body_weight_log.dart';
import '../../domain/entities/exercise_history_summary.dart';
import '../../domain/entities/machine.dart';

abstract class WorkoutLocalDataSource {
  Future<List<Exercise>> getExercises();
  Future<List<Routine>> getRoutines();
  Future<int> startSession(int routineId, String routineName);
  Future<int> logSet(WorkoutSet set);
  Future<void> updateSet(WorkoutSet set);
  Future<void> deleteSet(int setId);
  Future<void> toggleSetWarmup(int setId, bool isWarmup);
  Future<void> endSession(int sessionId);
  Future<void> deleteSession(int sessionId);
  Future<void> updateSessionNotes(int sessionId, String notes);
  Future<List<RoutineExerciseDetail>> getExercisesForRoutine(int routineId);
  Future<List<WorkoutSessionSummary>> getCompletedSessions();
  Future<List<WorkoutSet>> getSetsForSession(int sessionId);
  Future<Map<int, Exercise>> getExerciseInfoForSession(int sessionId);
  Future<Map<int, Map<String, dynamic>>> getBestSetsForExercises(List<int> exerciseIds);
  Future<Map<int, Map<String, dynamic>>> getLatestSetsForExercises(List<int> exerciseIds);
  Future<Map<int, Map<String, dynamic>>> getLatestSetsForExercisesInRoutine(List<int> exerciseIds, int routineId);
  Future<List<WorkoutSet>> getPreviousSetsForRoutine(int routineId);
  Future<WorkoutSession?> getPreviousSession(int routineId, int currentSessionId);
  
  Future<int> createRoutine(String name);
  Future<void> updateRoutineName(int routineId, String name);
  Future<void> deleteRoutine(int routineId);
  Future<List<Map<String, dynamic>>> getRoutinesWithExerciseInfo();

  // Part B Methods
  Future<void> addExerciseToRoutine(int routineId, int exerciseId, int sequenceOrder, int targetSets, String targetReps);
  Future<void> removeExerciseFromRoutine(int routineId, int exerciseId);
  Future<void> updateExerciseTargets(int routineId, int exerciseId, int targetSets, String targetReps);
  Future<void> updateExerciseOrder(int routineId, List<int> exerciseIdsInOrder);
  Future<int> getNextSequenceOrder(int routineId);
  Future<void> updateSupersetGroup(int routineId, int exerciseId, int? newGroupId);

  // Exercise Library Methods
  Future<int> createExercise(String name, String bodyPart, String weightUnit, {int? machineId});
  Future<void> updateExercise(int exerciseId, String name, String bodyPart, String weightUnit, {int? machineId});
  Future<void> deleteExercise(int exerciseId);
  Future<int> getExerciseUsageCount(int exerciseId);
  Future<int> getExerciseHistoryCount(int exerciseId);
  Future<List<String>> getDistinctBodyParts();
  Future<bool> exerciseNameExists(String name, {int? excludeId});
  Future<ExerciseHistorySummary> getExerciseHistory(int exerciseId);

  // Alternatives Methods
  Future<void> linkAlternativeExercises(int exerciseId1, int exerciseId2);
  Future<void> unlinkAlternativeExercises(int exerciseId1, int exerciseId2);
  Future<List<Exercise>> getAlternativesForExercise(int exerciseId);
  Future<Map<int, List<Exercise>>> getAlternativesForExercises(List<int> exerciseIds);

  // Machine Methods
  Future<List<Machine>> getAllMachines();
  Future<int> createMachine(String name);
  Future<void> setExerciseMachine(int exerciseId, int? machineId);
  Future<void> deleteMachine(int machineId);

  // Dashboard Methods
  Future<WeeklyStats> getWeeklyStats();
  Future<List<double>> getWeeklyVolumeChart();
  Future<List<WorkoutSessionSummary>> getRecentSessions(int limit);
  Future<int?> getLastUsedRoutineId();

  // PR Methods
  Future<bool> isPersonalRecord(int exerciseId, double weight, int reps, int currentSetId);
  Future<int> countPRsInSession(int sessionId);

  // Body Weight Methods
  Future<void> saveBodyWeightLog(BodyWeightLog log);
  Future<void> deleteBodyWeightLog(String id);
  Future<List<BodyWeightLog>> getBodyWeightLogs();
}

class WorkoutLocalDataSourceImpl implements WorkoutLocalDataSource {
  final DatabaseHelper dbHelper;

  WorkoutLocalDataSourceImpl(this.dbHelper);

  @override
  Future<List<Exercise>> getExercises() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('exercises');
    return maps.map((e) => Exercise.fromJson(e)).toList();
  }

  @override
  Future<List<Routine>> getRoutines() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('routines');
    return maps.map((e) => Routine.fromJson(e)).toList();
  }

  @override
  Future<int> startSession(int routineId, String routineName) async {
    try {
      final db = await dbHelper.database;
      final session = WorkoutSession(
        startTimestamp: DateTime.now().millisecondsSinceEpoch,
        routineId: routineId,
        routineNameSnapshot: routineName,
      );
      return await db.insert('workout_sessions', session.toJson());
    } catch (e) {
      throw DatabaseOperationException('Failed to start session: $e');
    }
  }

  @override
  Future<int> logSet(WorkoutSet set) async {
    try {
      final db = await dbHelper.database;
      return await db.insert('workout_sets', set.toJson());
    } catch (e) {
      throw DatabaseOperationException('Failed to log set: $e');
    }
  }

  @override
  Future<void> updateSet(WorkoutSet set) async {
    try {
      final db = await dbHelper.database;
      await db.update(
        'workout_sets',
        set.toJson(),
        where: 'id = ?',
        whereArgs: [set.id],
      );
    } catch (e) {
      throw DatabaseOperationException('Failed to update set: $e');
    }
  }

  @override
  Future<void> deleteSet(int setId) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'workout_sets',
        where: 'id = ?',
        whereArgs: [setId],
      );
    } catch (e) {
      throw DatabaseOperationException('Failed to delete set: $e');
    }
  }

  @override
  Future<void> toggleSetWarmup(int setId, bool isWarmup) async {
    try {
      final db = await dbHelper.database;
      await db.update(
        'workout_sets',
        {'isWarmup': isWarmup ? 1 : 0},
        where: 'id = ?',
        whereArgs: [setId],
      );
    } catch (e) {
      throw DatabaseOperationException('Failed to toggle set warmup: $e');
    }
  }

  @override
  Future<void> endSession(int sessionId) async {
    try {
      final db = await dbHelper.database;
      await db.update(
        'workout_sessions',
        {'endTimestamp': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [sessionId],
      );
    } catch (e) {
      throw DatabaseOperationException('Failed to end session: $e');
    }
  }

  @override
  Future<List<RoutineExerciseDetail>> getExercisesForRoutine(int routineId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT e.id AS exerciseId, e.name AS exerciseName, e.bodyPart, e.weightUnit, e.machineId, ref.sequenceOrder, ref.targetSets, ref.targetReps, ref.supersetGroup
      FROM routine_exercise_cross_ref ref
      INNER JOIN exercises e ON ref.exerciseId = e.id
      WHERE ref.routineId = ?
      ORDER BY ref.sequenceOrder ASC
    ''', [routineId]);
    return maps.map((e) => RoutineExerciseDetail.fromJson(e)).toList();
  }

  @override
  Future<List<WorkoutSessionSummary>> getCompletedSessions() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT ws.*, COUNT(s.id) as totalSets, 
             SUM(CASE WHEN e.weightUnit IN ('kg', 'lbs') AND coalesce(s.isWarmup, 0) = 0 THEN s.weight * s.reps ELSE 0 END) as totalVolume
      FROM workout_sessions ws
      LEFT JOIN workout_sets s ON ws.id = s.sessionId
      LEFT JOIN exercises e ON s.exerciseId = e.id
      WHERE ws.endTimestamp IS NOT NULL
      GROUP BY ws.id
      ORDER BY ws.startTimestamp DESC
    ''');

    return maps.map((map) {
      return WorkoutSessionSummary(
        session: WorkoutSession.fromJson(map),
        totalSets: map['totalSets'] as int? ?? 0,
        totalVolume: (map['totalVolume'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }

  @override
  Future<void> deleteSession(int sessionId) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'workout_sessions',
        where: 'id = ?',
        whereArgs: [sessionId],
      );
    } catch (e) {
      throw DatabaseOperationException('Failed to delete workout session: $e');
    }
  }

  @override
  Future<void> updateSessionNotes(int sessionId, String notes) async {
    try {
      final db = await dbHelper.database;
      await db.update(
        'workout_sessions',
        {'notes': notes},
        where: 'id = ?',
        whereArgs: [sessionId],
      );
    } catch (e) {
      throw DatabaseOperationException('Failed to update session notes: $e');
    }
  }

  @override
  Future<WorkoutSession?> getPreviousSession(int routineId, int currentSessionId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'workout_sessions',
        where: 'routineId = ? AND id != ? AND endTimestamp IS NOT NULL',
        whereArgs: [routineId, currentSessionId],
        orderBy: 'startTimestamp DESC',
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return WorkoutSession.fromJson(maps.first);
    } catch (e) {
      throw DatabaseOperationException('Failed to get previous session: $e');
    }
  }

  @override
  Future<List<WorkoutSet>> getSetsForSession(int sessionId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_sets',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'id ASC',
    );
    return maps.map((e) => WorkoutSet.fromJson(e)).toList();
  }

  @override
  Future<Map<int, Exercise>> getExerciseInfoForSession(int sessionId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT e.* 
      FROM workout_sets ws
      INNER JOIN exercises e ON ws.exerciseId = e.id
      WHERE ws.sessionId = ?
      GROUP BY e.id
    ''', [sessionId]);
    
    return {
      for (var map in maps) map['id'] as int: Exercise.fromJson(map),
    };
  }

  @override
  Future<Map<int, Map<String, dynamic>>> getBestSetsForExercises(List<int> exerciseIds) async {
    if (exerciseIds.isEmpty) return {};
    
    final db = await dbHelper.database;
    final placeholders = List.filled(exerciseIds.length, '?').join(',');
    
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT ws.exerciseId, ws.weight, ws.reps, ws.customWeight
      FROM workout_sets ws
      INNER JOIN workout_sessions s ON ws.sessionId = s.id
      WHERE ws.exerciseId IN ($placeholders)
      AND s.endTimestamp IS NOT NULL
      AND coalesce(ws.isWarmup, 0) = 0
      ORDER BY ws.exerciseId, ws.weight DESC, ws.reps DESC
    ''', exerciseIds);

    final Map<int, Map<String, dynamic>> results = {};
    for (var map in maps) {
      final exId = map['exerciseId'] as int;
      if (!results.containsKey(exId)) {
        results[exId] = map;
      }
    }
    return results;
  }

  @override
  Future<Map<int, Map<String, dynamic>>> getLatestSetsForExercises(List<int> exerciseIds) async {
    if (exerciseIds.isEmpty) return {};

    final db = await dbHelper.database;
    final placeholders = List.filled(exerciseIds.length, '?').join(',');

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT ws.exerciseId, ws.weight, ws.reps, ws.customWeight
      FROM workout_sets ws
      INNER JOIN workout_sessions s ON ws.sessionId = s.id
      WHERE ws.exerciseId IN ($placeholders)
      AND s.endTimestamp IS NOT NULL
      ORDER BY ws.id DESC
    ''', exerciseIds);

    final Map<int, Map<String, dynamic>> results = {};
    for (var map in maps) {
      final exId = map['exerciseId'] as int;
      if (!results.containsKey(exId)) {
        results[exId] = map;
      }
    }
    return results;
  }

  @override
  Future<Map<int, Map<String, dynamic>>> getLatestSetsForExercisesInRoutine(List<int> exerciseIds, int routineId) async {
    if (exerciseIds.isEmpty) return {};

    final db = await dbHelper.database;
    final placeholders = List.filled(exerciseIds.length, '?').join(',');

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT ws.exerciseId, ws.weight, ws.reps, ws.customWeight
      FROM workout_sets ws
      INNER JOIN workout_sessions s ON ws.sessionId = s.id
      WHERE ws.exerciseId IN ($placeholders)
      AND s.endTimestamp IS NOT NULL
      AND s.routineId = ?
      ORDER BY ws.id DESC
    ''', [...exerciseIds, routineId]);

    final Map<int, Map<String, dynamic>> results = {};
    for (var map in maps) {
      final exId = map['exerciseId'] as int;
      if (!results.containsKey(exId)) {
        results[exId] = map;
      }
    }
    return results;
  }

  @override
  Future<List<WorkoutSet>> getPreviousSetsForRoutine(int routineId) async {
    final db = await dbHelper.database;
    final sessions = await db.rawQuery('''
      SELECT id FROM workout_sessions
      WHERE routineId = ? AND endTimestamp IS NOT NULL
      ORDER BY endTimestamp DESC
      LIMIT 1
    ''', [routineId]);
    
    if (sessions.isEmpty) return [];
    
    final sessionId = sessions.first['id'] as int;
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_sets',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'id ASC',
    );
    return maps.map((e) => WorkoutSet.fromJson(e)).toList();
  }

  @override
  Future<int> createRoutine(String name) async {
    try {
      final db = await dbHelper.database;
      return await db.insert('routines', {'name': name});
    } catch (e) {
      throw DatabaseOperationException('Failed to create routine: $e');
    }
  }

  @override
  Future<void> updateRoutineName(int routineId, String name) async {
    try {
      final db = await dbHelper.database;
      await db.update(
        'routines',
        {'name': name},
        where: 'id = ?',
        whereArgs: [routineId],
      );
    } catch (e) {
      throw DatabaseOperationException('Failed to update routine name: $e');
    }
  }

  @override
  Future<void> deleteRoutine(int routineId) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'routines',
        where: 'id = ?',
        whereArgs: [routineId],
      );
    } catch (e) {
      throw DatabaseOperationException('Failed to delete routine: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRoutinesWithExerciseInfo() async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT r.id, r.name,
             COUNT(ref.exerciseId) AS exerciseCount,
             GROUP_CONCAT(e.name, ', ') AS exerciseNames
      FROM routines r
      LEFT JOIN routine_exercise_cross_ref ref ON r.id = ref.routineId
      LEFT JOIN exercises e ON ref.exerciseId = e.id
      GROUP BY r.id
      ORDER BY r.name ASC
    ''');
  }

  @override
  Future<void> addExerciseToRoutine(int routineId, int exerciseId, int sequenceOrder, int targetSets, String targetReps) async {
    try {
      final db = await dbHelper.database;
      await db.insert('routine_exercise_cross_ref', {
        'routineId': routineId,
        'exerciseId': exerciseId,
        'sequenceOrder': sequenceOrder,
        'targetSets': targetSets,
        'targetReps': targetReps,
        'supersetGroup': null,
      });
    } catch (e) {
      throw DatabaseOperationException('Failed to add exercise to routine: $e');
    }
  }

  @override
  Future<void> removeExerciseFromRoutine(int routineId, int exerciseId) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'routine_exercise_cross_ref',
        where: 'routineId = ? AND exerciseId = ?',
        whereArgs: [routineId, exerciseId],
      );
    } catch (e) {
      throw DatabaseOperationException('Failed to remove exercise from routine: $e');
    }
  }

  @override
  Future<void> updateExerciseTargets(int routineId, int exerciseId, int targetSets, String targetReps) async {
    try {
      final db = await dbHelper.database;
      await db.update(
        'routine_exercise_cross_ref',
        {'targetSets': targetSets, 'targetReps': targetReps},
        where: 'routineId = ? AND exerciseId = ?',
        whereArgs: [routineId, exerciseId],
      );
    } catch (e) {
      throw DatabaseOperationException('Failed to update exercise targets: $e');
    }
  }



  @override
  Future<void> updateExerciseOrder(int routineId, List<int> exerciseIdsInOrder) async {
    try {
      final db = await dbHelper.database;
      await db.transaction((txn) async {
        for (int i = 0; i < exerciseIdsInOrder.length; i++) {
          await txn.update(
            'routine_exercise_cross_ref',
            {'sequenceOrder': i + 1},
            where: 'routineId = ? AND exerciseId = ?',
            whereArgs: [routineId, exerciseIdsInOrder[i]],
          );
        }
      });
    } catch (e) {
      throw DatabaseOperationException('Failed to update exercise order: $e');
    }
  }

  @override
  Future<int> getNextSequenceOrder(int routineId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(MAX(sequenceOrder), 0) + 1 AS nextOrder FROM routine_exercise_cross_ref WHERE routineId = ?',
      [routineId],
    );
    return result.first['nextOrder'] as int;
  }

  @override
  Future<void> updateSupersetGroup(int routineId, int exerciseId, int? newGroupId) async {
    try {
      final db = await dbHelper.database;
      await db.update(
        'routine_exercise_cross_ref',
        {'supersetGroup': newGroupId},
        where: 'routineId = ? AND exerciseId = ?',
        whereArgs: [routineId, exerciseId],
      );
    } catch (e) {
      throw DatabaseOperationException('Failed to update superset group: $e');
    }
  }

  @override
  Future<int> createExercise(String name, String bodyPart, String weightUnit, {int? machineId}) async {
    try {
      final db = await dbHelper.database;
      final existing = await db.query('exercises', where: 'LOWER(name) = LOWER(?)', whereArgs: [name]);
      if (existing.isNotEmpty) {
        throw DatabaseOperationException('An exercise with this name already exists.');
      }
      return await db.insert('exercises', {
        'name': name,
        'bodyPart': bodyPart,
        'weightUnit': weightUnit,
        'machineId': machineId,
      });
    } catch (e) {
      if (e is DatabaseOperationException) rethrow;
      throw DatabaseOperationException('Failed to create exercise: $e');
    }
  }

  @override
  Future<void> updateExercise(int exerciseId, String name, String bodyPart, String weightUnit, {int? machineId}) async {
    try {
      final db = await dbHelper.database;
      final existing = await db.query('exercises', where: 'LOWER(name) = LOWER(?) AND id != ?', whereArgs: [name, exerciseId]);
      if (existing.isNotEmpty) {
        throw DatabaseOperationException('An exercise with this name already exists.');
      }
      await db.update('exercises', {
        'name': name,
        'bodyPart': bodyPart,
        'weightUnit': weightUnit,
        'machineId': machineId,
      }, where: 'id = ?', whereArgs: [exerciseId]);
    } catch (e) {
      if (e is DatabaseOperationException) rethrow;
      throw DatabaseOperationException('Failed to update exercise: $e');
    }
  }

  @override
  Future<void> deleteExercise(int exerciseId) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'exercises',
        where: 'id = ?',
        whereArgs: [exerciseId],
      );
    } catch (e) {
      throw DatabaseOperationException('Failed to delete exercise: $e');
    }
  }

  @override
  Future<int> getExerciseUsageCount(int exerciseId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM routine_exercise_cross_ref WHERE exerciseId = ?',
      [exerciseId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<int> getExerciseHistoryCount(int exerciseId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM workout_sets WHERE exerciseId = ?',
      [exerciseId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<List<String>> getDistinctBodyParts() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT DISTINCT bodyPart FROM exercises ORDER BY bodyPart ASC');
    return result.map((row) => row['bodyPart'] as String).toList();
  }

  @override
  Future<bool> exerciseNameExists(String name, {int? excludeId}) async {
    final db = await dbHelper.database;
    String query = 'SELECT COUNT(*) as count FROM exercises WHERE LOWER(name) = LOWER(?)';
    List<dynamic> args = [name];
    
    if (excludeId != null) {
      query += ' AND id != ?';
      args.add(excludeId);
    }
    
    final result = await db.rawQuery(query, args);
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  @override
  Future<int?> getLastUsedRoutineId() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT routineId FROM workout_sessions 
      WHERE routineId IS NOT NULL 
      ORDER BY startTimestamp DESC LIMIT 1
    ''');
    if (result.isEmpty) return null;
    return result.first['routineId'] as int?;
  }

  @override
  Future<List<WorkoutSessionSummary>> getRecentSessions(int limit) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT ws.*, COUNT(s.id) as totalSets, 
             SUM(CASE WHEN e.weightUnit IN ('kg', 'lbs') AND coalesce(s.isWarmup, 0) = 0 THEN s.weight * s.reps ELSE 0 END) as totalVolume
      FROM workout_sessions ws
      LEFT JOIN workout_sets s ON ws.id = s.sessionId
      LEFT JOIN exercises e ON s.exerciseId = e.id
      WHERE ws.endTimestamp IS NOT NULL
      GROUP BY ws.id
      ORDER BY ws.startTimestamp DESC
      LIMIT ?
    ''', [limit]);

    return maps.map((map) {
      return WorkoutSessionSummary(
        session: WorkoutSession.fromJson(map),
        totalSets: map['totalSets'] as int? ?? 0,
        totalVolume: (map['totalVolume'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }

  @override
  Future<WeeklyStats> getWeeklyStats() async {
    final sessions = await getCompletedSessions();
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    
    int weeklySessions = 0;
    double weeklyVolume = 0.0;
    
    for (var s in sessions) {
      final date = DateTime.fromMillisecondsSinceEpoch(s.session.startTimestamp);
      if (date.isAfter(startOfWeek) || date.isAtSameMomentAs(startOfWeek)) {
        weeklySessions++;
        weeklyVolume += s.totalVolume;
      }
    }
    
    int streak = 0;
    DateTime? lastDate;
    for (var s in sessions) {
      final date = DateTime.fromMillisecondsSinceEpoch(s.session.startTimestamp);
      final dayStart = DateTime(date.year, date.month, date.day);
      
      if (lastDate == null) {
        final today = DateTime(now.year, now.month, now.day);
        final diff = today.difference(dayStart).inDays;
        if (diff > 1) {
          break; // Streak broken before it started
        }
        streak = 1;
        lastDate = dayStart;
      } else {
        final diff = lastDate.difference(dayStart).inDays;
        if (diff == 0) continue; 
        if (diff == 1) {
          streak++;
          lastDate = dayStart;
        } else {
          break; // Streak broken
        }
      }
    }
    
    return WeeklyStats(
      sessionsCount: weeklySessions,
      totalVolume: weeklyVolume,
      streak: streak,
    );
  }

  @override
  Future<List<double>> getWeeklyVolumeChart() async {
    final sessions = await getCompletedSessions();
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    
    List<double> chart = List.filled(7, 0.0);
    
    for (var s in sessions) {
      final date = DateTime.fromMillisecondsSinceEpoch(s.session.startTimestamp);
      if (date.isAfter(startOfWeek) || date.isAtSameMomentAs(startOfWeek)) {
        final dayIndex = date.weekday - 1; // 0=Mon, 6=Sun
        chart[dayIndex] += s.totalVolume;
      }
    }
    
    return chart;
  }

  @override
  Future<void> linkAlternativeExercises(int exerciseId1, int exerciseId2) async {
    if (exerciseId1 == exerciseId2) return;
    
    final id1 = exerciseId1 < exerciseId2 ? exerciseId1 : exerciseId2;
    final id2 = exerciseId1 < exerciseId2 ? exerciseId2 : exerciseId1;
    
    try {
      final db = await dbHelper.database;
      await db.insert('exercise_alternatives', {
        'exerciseId1': id1,
        'exerciseId2': id2,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    } catch (e) {
      throw DatabaseOperationException('Failed to link alternative exercises: $e');
    }
  }

  @override
  Future<void> unlinkAlternativeExercises(int exerciseId1, int exerciseId2) async {
    final id1 = exerciseId1 < exerciseId2 ? exerciseId1 : exerciseId2;
    final id2 = exerciseId1 < exerciseId2 ? exerciseId2 : exerciseId1;
    
    try {
      final db = await dbHelper.database;
      await db.delete(
        'exercise_alternatives',
        where: 'exerciseId1 = ? AND exerciseId2 = ?',
        whereArgs: [id1, id2],
      );
    } catch (e) {
      throw DatabaseOperationException('Failed to unlink alternative exercises: $e');
    }
  }

  @override
  Future<List<Exercise>> getAlternativesForExercise(int exerciseId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT e.* FROM exercises e
      INNER JOIN exercise_alternatives ea 
        ON (ea.exerciseId1 = e.id OR ea.exerciseId2 = e.id)
      WHERE (ea.exerciseId1 = ? OR ea.exerciseId2 = ?)
        AND e.id != ?
      ORDER BY e.name ASC
    ''', [exerciseId, exerciseId, exerciseId]);
    return maps.map((e) => Exercise.fromJson(e)).toList();
  }

  @override
  Future<Map<int, List<Exercise>>> getAlternativesForExercises(List<int> exerciseIds) async {
    if (exerciseIds.isEmpty) return {};
    
    final Map<int, List<Exercise>> results = {};
    for (var id in exerciseIds) {
      results[id] = await getAlternativesForExercise(id);
    }
    return results;
  }

  @override
  Future<bool> isPersonalRecord(int exerciseId, double weight, int reps, int currentSetId) async {
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count FROM workout_sets ws
        INNER JOIN workout_sessions s ON ws.sessionId = s.id
        WHERE ws.exerciseId = ?
        AND (
          ws.weight > ? + 0.001 
          OR (ABS(ws.weight - ?) <= 0.001 AND ws.reps >= ?)
        )
        AND ws.id < ?
        AND s.endTimestamp IS NOT NULL
        AND coalesce(ws.isWarmup, 0) = 0
      ''', [exerciseId, weight, weight, reps, currentSetId]);
      
      final count = result.first['count'] as int;
      return count == 0 && weight > 0;
    } catch (e) {
      throw DatabaseOperationException('Failed to check personal record: $e');
    }
  }

  @override
  Future<int> countPRsInSession(int sessionId) async {
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count FROM workout_sets ws1
        WHERE ws1.sessionId = ?
        AND ws1.weight > 0
        AND coalesce(ws1.isWarmup, 0) = 0
        AND NOT EXISTS (
          SELECT 1 FROM workout_sets ws2
          INNER JOIN workout_sessions s2 ON ws2.sessionId = s2.id
          WHERE ws2.exerciseId = ws1.exerciseId
          AND (
            ws2.weight > ws1.weight + 0.001
            OR (ABS(ws2.weight - ws1.weight) <= 0.001 AND ws2.reps >= ws1.reps)
          )
          AND ws2.id < ws1.id
          AND s2.endTimestamp IS NOT NULL
          AND coalesce(ws2.isWarmup, 0) = 0
        )
      ''', [sessionId]);
      
      return result.first['count'] as int;
    } catch (e) {
      throw DatabaseOperationException('Failed to count PRs in session: $e');
    }
  }

  @override
  Future<void> saveBodyWeightLog(BodyWeightLog log) async {
    try {
      final db = await dbHelper.database;
      await db.insert('body_weight_logs', {
        'id': log.id,
        'timestamp': log.date.millisecondsSinceEpoch,
        'weight': log.weight,
        'bodyFatPercentage': log.bodyFatPercentage,
        'muscleMass': log.muscleMass,
        'waist': log.waist,
        'chest': log.chest,
        'arms': log.arms,
        'notes': log.notes,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw DatabaseOperationException('Failed to save body weight log: $e');
    }
  }

  @override
  Future<void> deleteBodyWeightLog(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'body_weight_logs',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseOperationException('Failed to delete body weight log: $e');
    }
  }

  @override
  Future<List<BodyWeightLog>> getBodyWeightLogs() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'body_weight_logs',
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => BodyWeightLog(
      id: map['id'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      weight: map['weight'] as double,
      bodyFatPercentage: map['bodyFatPercentage'] as double?,
      muscleMass: map['muscleMass'] as double?,
      waist: map['waist'] as double?,
      chest: map['chest'] as double?,
      arms: map['arms'] as double?,
      notes: map['notes'] as String?,
    )).toList();
  }

  @override
  Future<ExerciseHistorySummary> getExerciseHistory(int exerciseId) async {
    final db = await dbHelper.database;
    
    final exerciseMaps = await db.query('exercises', where: 'id = ?', whereArgs: [exerciseId]);
    if (exerciseMaps.isEmpty) throw DatabaseOperationException('Exercise not found');
    final exercise = Exercise.fromJson(exerciseMaps.first);

    final bestSetMaps = await db.rawQuery('''
      SELECT * FROM workout_sets 
      WHERE exerciseId = ? AND coalesce(isWarmup, 0) = 0
      ORDER BY weight DESC, reps DESC 
      LIMIT 1
    ''', [exerciseId]);
    WorkoutSet? allTimeBest = bestSetMaps.isNotEmpty ? WorkoutSet.fromJson(bestSetMaps.first) : null;

    final sessionsWithSets = await db.rawQuery('''
      SELECT s.* 
      FROM workout_sessions s
      JOIN workout_sets ws ON ws.sessionId = s.id
      WHERE ws.exerciseId = ? AND s.endTimestamp IS NOT NULL
      GROUP BY s.id
      ORDER BY s.startTimestamp ASC
    ''', [exerciseId]);

    List<WorkoutSession> recentSessions = sessionsWithSets.map((m) => WorkoutSession.fromJson(m)).toList().reversed.toList();
    
    final setsMapList = await db.rawQuery('''
      SELECT ws.*, s.startTimestamp
      FROM workout_sets ws
      JOIN workout_sessions s ON s.id = ws.sessionId
      WHERE ws.exerciseId = ? AND coalesce(ws.isWarmup, 0) = 0 AND s.endTimestamp IS NOT NULL
      ORDER BY s.startTimestamp ASC, ws.id ASC
    ''', [exerciseId]);

    double allTimeMaxWeight = -1;
    int allTimeMaxReps = -1;
    
    Map<int, double> volumePerSession = {};
    Map<int, bool> hasPRPerSession = {};
    Map<int, int> timestampPerSession = {};

    for (var row in setsMapList) {
      int sessionId = row['sessionId'] as int;
      int timestamp = row['startTimestamp'] as int;
      double weight = (row['weight'] as num).toDouble();
      int reps = row['reps'] as int;

      timestampPerSession[sessionId] = timestamp;
      
      if (exercise.weightUnit == 'kg' || exercise.weightUnit == 'lbs') {
        volumePerSession[sessionId] = (volumePerSession[sessionId] ?? 0.0) + (weight * reps);
        
        bool isPR = false;
        if (weight > allTimeMaxWeight + 0.001) {
          isPR = true;
          allTimeMaxWeight = weight;
          allTimeMaxReps = reps;
        } else if ((weight - allTimeMaxWeight).abs() <= 0.001 && reps > allTimeMaxReps) {
          isPR = true;
          allTimeMaxReps = reps;
        }
        
        if (isPR) {
          hasPRPerSession[sessionId] = true;
        }
      }
    }

    List<SessionVolume> volumeHistory = [];
    for (var sessionId in timestampPerSession.keys) {
      volumeHistory.add(SessionVolume(
        sessionId: sessionId,
        timestamp: timestampPerSession[sessionId]!,
        volume: volumePerSession[sessionId] ?? 0.0,
        hasPR: hasPRPerSession[sessionId] ?? false,
      ));
    }

    return ExerciseHistorySummary(
      exercise: exercise,
      allTimeBest: allTimeBest,
      volumeHistory: volumeHistory,
      recentSessions: recentSessions,
    );
  }

  @override
  Future<List<Machine>> getAllMachines() async {
    try {
      final db = await dbHelper.database;
      final results = await db.query('machines', orderBy: 'name COLLATE NOCASE ASC');
      return results.map((row) => Machine.fromJson(row)).toList();
    } catch (e) {
      throw DatabaseOperationException('Failed to load machines: $e');
    }
  }

  @override
  Future<int> createMachine(String name) async {
    try {
      final db = await dbHelper.database;
      
      // Check for duplicate name
      final existing = await db.query('machines', where: 'LOWER(name) = LOWER(?)', whereArgs: [name]);
      if (existing.isNotEmpty) {
        throw DatabaseOperationException('A machine with this name already exists.');
      }
      
      return await db.insert('machines', {'name': name});
    } catch (e) {
      if (e is DatabaseOperationException) rethrow;
      throw DatabaseOperationException('Failed to create machine: $e');
    }
  }

  @override
  Future<void> setExerciseMachine(int exerciseId, int? machineId) async {
    try {
      final db = await dbHelper.database;
      await db.update(
        'exercises',
        {'machineId': machineId},
        where: 'id = ?',
        whereArgs: [exerciseId],
      );
    } catch (e) {
      throw DatabaseOperationException('Failed to set machine for exercise: $e');
    }
  }

  @override
  Future<void> deleteMachine(int machineId) async {
    try {
      final db = await dbHelper.database;
      await db.delete('machines', where: 'id = ?', whereArgs: [machineId]);
    } catch (e) {
      throw DatabaseOperationException('Failed to delete machine: $e');
    }
  }
}
