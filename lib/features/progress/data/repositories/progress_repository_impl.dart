import 'package:iron_log/features/progress/data/datasources/progress_local_data_source.dart';
import 'package:iron_log/features/progress/domain/repositories/progress_repository.dart';
import 'package:iron_log/features/workout/domain/entities/body_weight_log.dart';
import 'package:iron_log/features/workout/domain/entities/exercise.dart';
import 'package:iron_log/features/workout/domain/entities/routine_exercise.dart';
import 'package:iron_log/features/workout/domain/entities/workout_session.dart';
import 'package:iron_log/features/workout/domain/entities/workout_set.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressLocalDataSource dataSource;

  ProgressRepositoryImpl(this.dataSource);

  @override
  Future<List<WorkoutSession>> getSessionsInRange(DateTime start, DateTime end) {
    return dataSource.getSessionsInRange(start, end);
  }

  @override
  Future<List<WorkoutSet>> getSetsForSessions(List<int> sessionIds) {
    return dataSource.getSetsForSessions(sessionIds);
  }

  @override
  Future<List<BodyWeightLog>> getBodyWeightLogsInRange(DateTime start, DateTime end) {
    return dataSource.getBodyWeightLogsInRange(start, end);
  }

  @override
  Future<Map<int, Exercise>> getExercisesForSets(List<WorkoutSet> sets) {
    return dataSource.getExercisesForSets(sets);
  }

  @override
  Future<Map<int, RoutineExercise>> getTargetsForSessions(List<int> sessionIds) {
    return dataSource.getTargetsForSessions(sessionIds);
  }
}
