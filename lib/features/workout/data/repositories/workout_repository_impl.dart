import '../datasources/workout_local_data_source.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/routine.dart';
import '../../domain/entities/workout_set.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/entities/routine_exercise_detail.dart';
import '../../domain/entities/workout_session_summary.dart';
import '../../domain/entities/routine_summary.dart';
import '../../domain/entities/weekly_stats.dart';
import '../../domain/entities/body_weight_log.dart';

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
  Future<int> logSet(WorkoutSet set) {
    return localDataSource.logSet(set);
  }

  @override
  Future<void> toggleSetWarmup(int setId, bool isWarmup) {
    return localDataSource.toggleSetWarmup(setId, isWarmup);
  }

  @override
  Future<void> endSession(int sessionId) {
    return localDataSource.endSession(sessionId);
  }

  @override
  Future<void> deleteSession(int sessionId) {
    return localDataSource.deleteSession(sessionId);
  }

  @override
  Future<void> updateSessionNotes(int sessionId, String notes) {
    return localDataSource.updateSessionNotes(sessionId, notes);
  }

  @override
  Future<List<RoutineExerciseDetail>> getExercisesForRoutine(int routineId) {
    return localDataSource.getExercisesForRoutine(routineId);
  }

  @override
  Future<List<WorkoutSessionSummary>> getCompletedSessions() {
    return localDataSource.getCompletedSessions();
  }

  @override
  Future<List<WorkoutSet>> getSetsForSession(int sessionId) {
    return localDataSource.getSetsForSession(sessionId);
  }

  @override
  Future<Map<int, Exercise>> getExerciseInfoForSession(int sessionId) {
    return localDataSource.getExerciseInfoForSession(sessionId);
  }

  @override
  Future<Map<int, Map<String, dynamic>>> getBestSetsForExercises(List<int> exerciseIds) {
    return localDataSource.getBestSetsForExercises(exerciseIds);
  }

  @override
  Future<Map<int, Map<String, dynamic>>> getLatestSetsForExercises(List<int> exerciseIds) {
    return localDataSource.getLatestSetsForExercises(exerciseIds);
  }

  @override
  Future<Map<int, Map<String, dynamic>>> getLatestSetsForExercisesInRoutine(List<int> exerciseIds, int routineId) {
    return localDataSource.getLatestSetsForExercisesInRoutine(exerciseIds, routineId);
  }

  @override
  Future<List<RoutineSummary>> getRoutinesWithInfo() async {
    final maps = await localDataSource.getRoutinesWithExerciseInfo();
    return maps.map((map) => RoutineSummary.fromJson(map)).toList();
  }

  @override
  Future<int> createRoutine(String name) {
    return localDataSource.createRoutine(name);
  }

  @override
  Future<void> updateRoutineName(int routineId, String name) {
    return localDataSource.updateRoutineName(routineId, name);
  }

  @override
  Future<void> deleteRoutine(int routineId) {
    return localDataSource.deleteRoutine(routineId);
  }

  @override
  Future<void> addExerciseToRoutine(int routineId, int exerciseId, int sequenceOrder, int targetSets, String targetReps, int restSeconds) {
    return localDataSource.addExerciseToRoutine(routineId, exerciseId, sequenceOrder, targetSets, targetReps, restSeconds);
  }

  @override
  Future<void> removeExerciseFromRoutine(int routineId, int exerciseId) {
    return localDataSource.removeExerciseFromRoutine(routineId, exerciseId);
  }

  @override
  Future<void> updateExerciseTargets(int routineId, int exerciseId, int targetSets, String targetReps) {
    return localDataSource.updateExerciseTargets(routineId, exerciseId, targetSets, targetReps);
  }

  @override
  Future<void> updateExerciseRestTime(int routineId, int exerciseId, int restSeconds) {
    return localDataSource.updateExerciseRestTime(routineId, exerciseId, restSeconds);
  }

  @override
  Future<void> updateExerciseOrder(int routineId, List<int> exerciseIdsInOrder) {
    return localDataSource.updateExerciseOrder(routineId, exerciseIdsInOrder);
  }

  @override
  Future<int> getNextSequenceOrder(int routineId) {
    return localDataSource.getNextSequenceOrder(routineId);
  }

  @override
  Future<int> createExercise(String name, String bodyPart, String weightUnit) {
    return localDataSource.createExercise(name, bodyPart, weightUnit);
  }

  @override
  Future<void> updateExercise(int exerciseId, String name, String bodyPart, String weightUnit) {
    return localDataSource.updateExercise(exerciseId, name, bodyPart, weightUnit);
  }

  @override
  Future<void> deleteExercise(int exerciseId) {
    return localDataSource.deleteExercise(exerciseId);
  }

  @override
  Future<int> getExerciseUsageCount(int exerciseId) {
    return localDataSource.getExerciseUsageCount(exerciseId);
  }

  @override
  Future<int> getExerciseHistoryCount(int exerciseId) {
    return localDataSource.getExerciseHistoryCount(exerciseId);
  }

  @override
  Future<List<String>> getDistinctBodyParts() {
    return localDataSource.getDistinctBodyParts();
  }

  @override
  Future<bool> exerciseNameExists(String name, {int? excludeId}) {
    return localDataSource.exerciseNameExists(name, excludeId: excludeId);
  }

  @override
  Future<void> linkAlternativeExercises(int exerciseId1, int exerciseId2) {
    return localDataSource.linkAlternativeExercises(exerciseId1, exerciseId2);
  }

  @override
  Future<void> unlinkAlternativeExercises(int exerciseId1, int exerciseId2) {
    return localDataSource.unlinkAlternativeExercises(exerciseId1, exerciseId2);
  }

  @override
  Future<List<Exercise>> getAlternativesForExercise(int exerciseId) {
    return localDataSource.getAlternativesForExercise(exerciseId);
  }

  @override
  Future<Map<int, List<Exercise>>> getAlternativesForExercises(List<int> exerciseIds) {
    return localDataSource.getAlternativesForExercises(exerciseIds);
  }

  @override
  Future<WeeklyStats> getWeeklyStats() {
    return localDataSource.getWeeklyStats();
  }

  @override
  Future<List<double>> getWeeklyVolumeChart() {
    return localDataSource.getWeeklyVolumeChart();
  }

  @override
  Future<List<WorkoutSessionSummary>> getRecentSessions(int limit) {
    return localDataSource.getRecentSessions(limit);
  }

  @override
  Future<RoutineSummary?> getLastUsedRoutine() async {
    final routineId = await localDataSource.getLastUsedRoutineId();
    if (routineId == null) return null;
    final routines = await getRoutinesWithInfo();
    try {
      return routines.firstWhere((r) => r.id == routineId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isPersonalRecord(int exerciseId, double weight, int reps, int currentSetId) {
    return localDataSource.isPersonalRecord(exerciseId, weight, reps, currentSetId);
  }

  @override
  Future<int> countPRsInSession(int sessionId) {
    return localDataSource.countPRsInSession(sessionId);
  }

  @override
  Future<void> saveBodyWeightLog(BodyWeightLog log) {
    return localDataSource.saveBodyWeightLog(log);
  }

  @override
  Future<void> deleteBodyWeightLog(String id) {
    return localDataSource.deleteBodyWeightLog(id);
  }

  @override
  Future<List<BodyWeightLog>> getBodyWeightLogs() {
    return localDataSource.getBodyWeightLogs();
  }
}
