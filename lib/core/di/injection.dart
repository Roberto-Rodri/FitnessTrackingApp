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

part 'injection.g.dart';

@Riverpod(keepAlive: true)
DatabaseHelper databaseHelper(DatabaseHelperRef ref) {
  return DatabaseHelper.instance;
}

@Riverpod(keepAlive: true)
WorkoutLocalDataSource workoutLocalDataSource(WorkoutLocalDataSourceRef ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return WorkoutLocalDataSourceImpl(dbHelper);
}

@Riverpod(keepAlive: true)
WorkoutRepository workoutRepository(WorkoutRepositoryRef ref) {
  final localDataSource = ref.watch(workoutLocalDataSourceProvider);
  return WorkoutRepositoryImpl(localDataSource);
}

@Riverpod(keepAlive: true)
UserPrefsLocalDataSource userPrefsLocalDataSource(UserPrefsLocalDataSourceRef ref) {
  return UserPrefsLocalDataSource();
}

@Riverpod(keepAlive: true)
UserPrefsRepository userPrefsRepository(UserPrefsRepositoryRef ref) {
  final localDataSource = ref.watch(userPrefsLocalDataSourceProvider);
  return UserPrefsRepositoryImpl(dataSource: localDataSource);
}

@Riverpod(keepAlive: true)
ProgramLocalDataSource programLocalDataSource(ProgramLocalDataSourceRef ref) {
  return ProgramLocalDataSourceImpl(ref.watch(databaseHelperProvider));
}

@Riverpod(keepAlive: true)
ProgramRepository programRepository(ProgramRepositoryRef ref) {
  return ProgramRepositoryImpl(ref.watch(programLocalDataSourceProvider));
}
