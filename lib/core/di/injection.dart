import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/database_helper.dart';
import '../../features/workout/data/datasources/workout_local_data_source.dart';
import '../../features/workout/data/repositories/workout_repository_impl.dart';
import '../../features/workout/domain/repositories/workout_repository.dart';
import '../../features/profile/data/datasources/user_prefs_local_data_source.dart';
import '../../features/profile/data/repositories/user_prefs_repository_impl.dart';
import '../../features/profile/domain/repositories/user_prefs_repository.dart';
import '../../features/program/data/datasources/program_local_data_source.dart';
import '../../features/program/data/repositories/program_repository_impl.dart';
import '../../features/program/domain/repositories/program_repository.dart';
import '../database/backup_local_data_source.dart';
import '../database/backup_repository.dart';
import '../../features/progress/data/datasources/progress_local_data_source.dart';
import '../../features/progress/data/repositories/progress_repository_impl.dart';
import '../../features/progress/domain/repositories/progress_repository.dart';

part 'injection.g.dart';

@Riverpod(keepAlive: true)
DatabaseHelper databaseHelper(Ref ref) {
  return DatabaseHelper.instance;
}

@Riverpod(keepAlive: true)
WorkoutLocalDataSource workoutLocalDataSource(Ref ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return WorkoutLocalDataSourceImpl(dbHelper);
}

@Riverpod(keepAlive: true)
WorkoutRepository workoutRepository(Ref ref) {
  final localDataSource = ref.watch(workoutLocalDataSourceProvider);
  return WorkoutRepositoryImpl(localDataSource);
}

@Riverpod(keepAlive: true)
UserPrefsLocalDataSource userPrefsLocalDataSource(Ref ref) {
  return UserPrefsLocalDataSource();
}

@Riverpod(keepAlive: true)
UserPrefsRepository userPrefsRepository(Ref ref) {
  final localDataSource = ref.watch(userPrefsLocalDataSourceProvider);
  return UserPrefsRepositoryImpl(dataSource: localDataSource);
}

@Riverpod(keepAlive: true)
ProgramLocalDataSource programLocalDataSource(Ref ref) {
  return ProgramLocalDataSourceImpl(ref.watch(databaseHelperProvider));
}

@Riverpod(keepAlive: true)
ProgramRepository programRepository(Ref ref) {
  return ProgramRepositoryImpl(ref.watch(programLocalDataSourceProvider));
}

@Riverpod(keepAlive: true)
BackupLocalDataSource backupLocalDataSource(Ref ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return BackupLocalDataSourceImpl(dbHelper);
}

@Riverpod(keepAlive: true)
BackupRepository backupRepository(Ref ref) {
  final localDataSource = ref.watch(backupLocalDataSourceProvider);
  return BackupRepositoryImpl(localDataSource);
}

@Riverpod(keepAlive: true)
ProgressLocalDataSource progressLocalDataSource(Ref ref) {
  return ProgressLocalDataSource(ref.watch(databaseHelperProvider));
}

@Riverpod(keepAlive: true)
ProgressRepository progressRepository(Ref ref) {
  return ProgressRepositoryImpl(ref.watch(progressLocalDataSourceProvider));
}

