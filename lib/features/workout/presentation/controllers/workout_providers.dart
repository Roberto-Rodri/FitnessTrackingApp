import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/datasources/workout_local_data_source.dart';
import '../../data/repositories/workout_repository_impl.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/entities/workout_set.dart';

part 'workout_providers.g.dart';

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

class ActiveWorkoutState {
  final int? sessionId;
  final List<WorkoutSet> sets;
  const ActiveWorkoutState({this.sessionId, this.sets = const []});

  ActiveWorkoutState copyWith({int? sessionId, List<WorkoutSet>? sets}) {
    return ActiveWorkoutState(
      sessionId: sessionId ?? this.sessionId,
      sets: sets ?? this.sets,
    );
  }
}

@Riverpod(keepAlive: true)
class WorkoutSessionNotifier extends _$WorkoutSessionNotifier {
  @override
  Future<ActiveWorkoutState> build() async {
    return const ActiveWorkoutState();
  }

  Future<void> startSession(int routineId, String name) async {
    if (state.isLoading) return; // Prevent double-clicks
    
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final repository = ref.read(workoutRepositoryProvider);
      final sessionId = await repository.startSession(routineId, name);
      
      print('Session started with ID: $sessionId');
      
      return ActiveWorkoutState(
        sessionId: sessionId,
        sets: [],
      );
    });
  }

  Future<void> logNewSet(WorkoutSet set) async {
    final currentState = state.value;
    if (currentState == null || currentState.sessionId == null) return;

    final setWithSession = set.copyWith(sessionId: currentState.sessionId!);

    // Optimistically update
    final newSets = [...currentState.sets, setWithSession];
    state = AsyncData(currentState.copyWith(sets: newSets));

    try {
      final repository = ref.read(workoutRepositoryProvider);
      await repository.logSet(setWithSession);
    } catch (e, st) {
      // Revert on failure
      state = AsyncError(e, st);
    }
  }
}
