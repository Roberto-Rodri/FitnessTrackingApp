import '../entities/exercise.dart';
import '../entities/routine.dart';
import '../entities/workout_set.dart';

abstract class WorkoutRepository {
  Future<List<Exercise>> getExercises();
  Future<List<Routine>> getRoutines();
  Future<int> startSession(int routineId, String routineName);
  Future<void> logSet(WorkoutSet set);
}
