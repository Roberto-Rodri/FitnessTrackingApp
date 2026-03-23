// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$databaseHelperHash() => r'8c627593850177edc8979b969ecde01b91f88714';

/// See also [databaseHelper].
@ProviderFor(databaseHelper)
final databaseHelperProvider = Provider<DatabaseHelper>.internal(
  databaseHelper,
  name: r'databaseHelperProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$databaseHelperHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseHelperRef = ProviderRef<DatabaseHelper>;
String _$workoutLocalDataSourceHash() =>
    r'1d5623f256507c56af00c773b3462689ae32be99';

/// See also [workoutLocalDataSource].
@ProviderFor(workoutLocalDataSource)
final workoutLocalDataSourceProvider =
    Provider<WorkoutLocalDataSource>.internal(
  workoutLocalDataSource,
  name: r'workoutLocalDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$workoutLocalDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WorkoutLocalDataSourceRef = ProviderRef<WorkoutLocalDataSource>;
String _$workoutRepositoryHash() => r'afc4d8a7680b77f7efe3bd431ff43e52a2efdf46';

/// See also [workoutRepository].
@ProviderFor(workoutRepository)
final workoutRepositoryProvider = Provider<WorkoutRepository>.internal(
  workoutRepository,
  name: r'workoutRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$workoutRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WorkoutRepositoryRef = ProviderRef<WorkoutRepository>;
String _$workoutSessionNotifierHash() =>
    r'156e9ec3ceb5331debd6b9f284f441b946675461';

/// See also [WorkoutSessionNotifier].
@ProviderFor(WorkoutSessionNotifier)
final workoutSessionNotifierProvider =
    AsyncNotifierProvider<WorkoutSessionNotifier, ActiveWorkoutState>.internal(
  WorkoutSessionNotifier.new,
  name: r'workoutSessionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$workoutSessionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WorkoutSessionNotifier = AsyncNotifier<ActiveWorkoutState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
