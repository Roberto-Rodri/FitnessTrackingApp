import 'package:iron_log/features/workout/domain/entities/body_weight_log.dart';
import 'package:iron_log/features/workout/domain/entities/exercise.dart';
import 'package:iron_log/features/workout/domain/entities/routine_exercise.dart';
import 'package:iron_log/features/workout/domain/entities/workout_session.dart';
import 'package:iron_log/features/workout/domain/entities/workout_set.dart';

abstract class ProgressRepository {
  Future<List<WorkoutSession>> getSessionsInRange(DateTime start, DateTime end);
  Future<List<WorkoutSet>> getSetsForSessions(List<int> sessionIds);
  Future<List<BodyWeightLog>> getBodyWeightLogsInRange(DateTime start, DateTime end);
  Future<Map<int, Exercise>> getExercisesForSets(List<WorkoutSet> sets);
  Future<Map<int, RoutineExercise>> getTargetsForSessions(List<int> sessionIds);
}
