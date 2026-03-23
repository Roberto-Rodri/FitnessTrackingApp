import '../datasources/workout_local_data_source.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/routine.dart';
import '../../domain/entities/workout_set.dart';
import '../../domain/repositories/workout_repository.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutLocalDataSource localDataSource;

  WorkoutRepositoryImpl(this.localDataSource);

  @override
  Future<List<Exercise>> getExercises() {
    return localDataSource.getExercises();
  }

  @override
  Future<List<Routine>> getRoutines() {
    return localDataSource.getRoutines();
  }

  @override
  Future<int> startSession(int routineId, String routineName) {
    return localDataSource.startSession(routineId, routineName);
  }

  @override
  Future<void> logSet(WorkoutSet set) {
    return localDataSource.logSet(set);
  }
}
