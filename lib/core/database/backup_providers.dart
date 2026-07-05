import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../di/injection.dart';

import '../../features/workout/presentation/controllers/workout_providers.dart';
import '../../features/program/presentation/controllers/program_providers.dart';
import '../../features/workout/presentation/controllers/body_weight_providers.dart';
import 'package:sqflite/sqflite.dart';

part 'backup_providers.g.dart';

class BackupStats {
  final int workouts;
  final int routines;
  final int exercises;

  BackupStats({
    required this.workouts,
    required this.routines,
    required this.exercises,
  });
}

@riverpod
Future<BackupStats> backupStats(BackupStatsRef ref) async {
  final dbHelper = ref.watch(databaseHelperProvider);
  final db = await dbHelper.database;
  
  final workoutsCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM workout_sessions')) ?? 0;
  final routinesCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM routines')) ?? 0;
  final exercisesCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM exercises')) ?? 0;

  return BackupStats(
    workouts: workoutsCount,
    routines: routinesCount,
    exercises: exercisesCount,
  );
}

@riverpod
class BackupController extends _$BackupController {
  @override
  FutureOr<void> build() {}

  Future<String> exportDatabase() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(backupRepositoryProvider);
      final path = await repository.exportDatabase();
      state = const AsyncData(null);
      return path;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> importDatabase(String jsonString) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(backupRepositoryProvider);
      await repository.importDatabase(jsonString);
      
      // Invalidate root providers
      ref.invalidate(allExercisesProvider);
      ref.invalidate(routineListProvider);
      ref.invalidate(completedSessionsProvider);
      ref.invalidate(bodyPartsProvider);
      ref.invalidate(weeklyStatsProvider);
      ref.invalidate(weeklyVolumeChartProvider);
      ref.invalidate(recentSessionsProvider);
      
      ref.invalidate(allProgramsProvider);
      ref.invalidate(activeProgramProvider);
      ref.invalidate(currentProgramDayProvider);
      ref.invalidate(completedProgramDaysProvider);
      
      ref.invalidate(bodyWeightLogsControllerProvider);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
