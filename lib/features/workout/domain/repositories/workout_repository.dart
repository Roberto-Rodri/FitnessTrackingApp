import '../entities/exercise.dart';
import '../entities/routine.dart';
import '../entities/workout_set.dart';
import '../entities/routine_exercise_detail.dart';
import '../entities/workout_session_summary.dart';
import '../entities/routine_summary.dart';
import '../entities/weekly_stats.dart';
import '../entities/body_weight_log.dart';

abstract class WorkoutRepository {
  Future<List<Exercise>> getExercises();
  Future<List<Routine>> getRoutines();
  Future<int> startSession(int routineId, String routineName);
  Future<int> logSet(WorkoutSet set);
  Future<void> endSession(int sessionId);
  Future<void> deleteSession(int sessionId);
  Future<void> updateSessionNotes(String sessionId, String notes);
  Future<List<RoutineExerciseDetail>> getExercisesForRoutine(int routineId);
  Future<List<WorkoutSessionSummary>> getCompletedSessions();
  Future<List<WorkoutSet>> getSetsForSession(int sessionId);
  Future<Map<int, Exercise>> getExerciseInfoForSession(int sessionId);
  Future<Map<int, Map<String, dynamic>>> getBestSetsForExercises(List<int> exerciseIds);
  Future<Map<int, Map<String, dynamic>>> getLatestSetsForExercises(List<int> exerciseIds);
  Future<Map<int, Map<String, dynamic>>> getLatestSetsForExercisesInRoutine(List<int> exerciseIds, int routineId);

  // Routine Management Methods
  Future<List<RoutineSummary>> getRoutinesWithInfo();
  Future<int> createRoutine(String name);
  Future<void> updateRoutineName(int routineId, String name);
  Future<void> deleteRoutine(int routineId);

  // Routine Exercises Methods
  Future<void> addExerciseToRoutine(int routineId, int exerciseId, int sequenceOrder, int targetSets, String targetReps, int restSeconds);
  Future<void> removeExerciseFromRoutine(int routineId, int exerciseId);
  Future<void> updateExerciseTargets(int routineId, int exerciseId, int targetSets, String targetReps);
  Future<void> updateExerciseRestTime(int routineId, int exerciseId, int restSeconds);
  Future<void> updateExerciseOrder(int routineId, List<int> exerciseIdsInOrder);
  Future<int> getNextSequenceOrder(int routineId);

  // Exercise Library Methods
  Future<int> createExercise(String name, String bodyPart, String weightUnit);
  Future<void> updateExercise(int exerciseId, String name, String bodyPart, String weightUnit);
  Future<void> deleteExercise(int exerciseId);
  Future<int> getExerciseUsageCount(int exerciseId);
  Future<int> getExerciseHistoryCount(int exerciseId);
  Future<List<String>> getDistinctBodyParts();
  Future<bool> exerciseNameExists(String name, {int? excludeId});

  // Alternatives Methods
  Future<void> linkAlternativeExercises(int exerciseId1, int exerciseId2);
  Future<void> unlinkAlternativeExercises(int exerciseId1, int exerciseId2);
  Future<List<Exercise>> getAlternativesForExercise(int exerciseId);
  Future<Map<int, List<Exercise>>> getAlternativesForExercises(List<int> exerciseIds);

  // Dashboard Methods
  Future<WeeklyStats> getWeeklyStats();
  Future<List<double>> getWeeklyVolumeChart();
  Future<List<WorkoutSessionSummary>> getRecentSessions(int limit);
  Future<RoutineSummary?> getLastUsedRoutine();

  // PR Methods
  Future<bool> isPersonalRecord(int exerciseId, double weight, int reps, int currentSetId);
  Future<int> countPRsInSession(int sessionId);

  // Body Weight Methods
  Future<void> saveBodyWeightLog(BodyWeightLog log);
  Future<void> deleteBodyWeightLog(String id);
  Future<List<BodyWeightLog>> getBodyWeightLogs();
}
