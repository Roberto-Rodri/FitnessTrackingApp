import '../../../../core/database/database_helper.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/routine.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/entities/workout_set.dart';

abstract class WorkoutLocalDataSource {
  Future<List<Exercise>> getExercises();
  Future<List<Routine>> getRoutines();
  Future<int> startSession(int routineId, String routineName);
  Future<void> logSet(WorkoutSet set);
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
    final db = await dbHelper.database;
    final session = WorkoutSession(
      startTimestamp: DateTime.now().millisecondsSinceEpoch,
      routineId: routineId,
      routineNameSnapshot: routineName,
    );
    return await db.insert('workout_sessions', session.toJson());
  }

  @override
  Future<void> logSet(WorkoutSet set) async {
    final db = await dbHelper.database;
    await db.insert('workout_sets', set.toJson());
  }
}
