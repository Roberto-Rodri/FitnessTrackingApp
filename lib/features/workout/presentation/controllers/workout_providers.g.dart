// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionPRCountHash() => r'3b415807c9bc44422ef166a0b62266d204725d28';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [sessionPRCount].
@ProviderFor(sessionPRCount)
const sessionPRCountProvider = SessionPRCountFamily();

/// See also [sessionPRCount].
class SessionPRCountFamily extends Family<AsyncValue<int>> {
  /// See also [sessionPRCount].
  const SessionPRCountFamily();

  /// See also [sessionPRCount].
  SessionPRCountProvider call(
    int sessionId,
  ) {
    return SessionPRCountProvider(
      sessionId,
    );
  }

  @override
  SessionPRCountProvider getProviderOverride(
    covariant SessionPRCountProvider provider,
  ) {
    return call(
      provider.sessionId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sessionPRCountProvider';
}

/// See also [sessionPRCount].
class SessionPRCountProvider extends AutoDisposeFutureProvider<int> {
  /// See also [sessionPRCount].
  SessionPRCountProvider(
    int sessionId,
  ) : this._internal(
          (ref) => sessionPRCount(
            ref as SessionPRCountRef,
            sessionId,
          ),
          from: sessionPRCountProvider,
          name: r'sessionPRCountProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionPRCountHash,
          dependencies: SessionPRCountFamily._dependencies,
          allTransitiveDependencies:
              SessionPRCountFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SessionPRCountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sessionId,
  }) : super.internal();

  final int sessionId;

  @override
  Override overrideWith(
    FutureOr<int> Function(SessionPRCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SessionPRCountProvider._internal(
        (ref) => create(ref as SessionPRCountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sessionId: sessionId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<int> createElement() {
    return _SessionPRCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionPRCountProvider && other.sessionId == sessionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sessionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SessionPRCountRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;
}

class _SessionPRCountProviderElement
    extends AutoDisposeFutureProviderElement<int> with SessionPRCountRef {
  _SessionPRCountProviderElement(super.provider);

  @override
  int get sessionId => (origin as SessionPRCountProvider).sessionId;
}

String _$completedSessionsHash() => r'c064dba278beab20092e3fcbc9c19a9489711922';

/// See also [completedSessions].
@ProviderFor(completedSessions)
final completedSessionsProvider =
    AutoDisposeFutureProvider<List<WorkoutSessionSummary>>.internal(
  completedSessions,
  name: r'completedSessionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$completedSessionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CompletedSessionsRef
    = AutoDisposeFutureProviderRef<List<WorkoutSessionSummary>>;
String _$filteredSessionsHash() => r'6937b8abcbd82f968030732ba9185fd8a2fa65c5';

/// See also [filteredSessions].
@ProviderFor(filteredSessions)
final filteredSessionsProvider =
    AutoDisposeFutureProvider<List<WorkoutSessionSummary>>.internal(
  filteredSessions,
  name: r'filteredSessionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredSessionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredSessionsRef
    = AutoDisposeFutureProviderRef<List<WorkoutSessionSummary>>;
String _$sessionSetsHash() => r'175cd83bb5c480add77063a836a535113ba847a8';

/// See also [sessionSets].
@ProviderFor(sessionSets)
const sessionSetsProvider = SessionSetsFamily();

/// See also [sessionSets].
class SessionSetsFamily extends Family<AsyncValue<List<WorkoutSet>>> {
  /// See also [sessionSets].
  const SessionSetsFamily();

  /// See also [sessionSets].
  SessionSetsProvider call(
    int sessionId,
  ) {
    return SessionSetsProvider(
      sessionId,
    );
  }

  @override
  SessionSetsProvider getProviderOverride(
    covariant SessionSetsProvider provider,
  ) {
    return call(
      provider.sessionId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sessionSetsProvider';
}

/// See also [sessionSets].
class SessionSetsProvider extends AutoDisposeFutureProvider<List<WorkoutSet>> {
  /// See also [sessionSets].
  SessionSetsProvider(
    int sessionId,
  ) : this._internal(
          (ref) => sessionSets(
            ref as SessionSetsRef,
            sessionId,
          ),
          from: sessionSetsProvider,
          name: r'sessionSetsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionSetsHash,
          dependencies: SessionSetsFamily._dependencies,
          allTransitiveDependencies:
              SessionSetsFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SessionSetsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sessionId,
  }) : super.internal();

  final int sessionId;

  @override
  Override overrideWith(
    FutureOr<List<WorkoutSet>> Function(SessionSetsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SessionSetsProvider._internal(
        (ref) => create(ref as SessionSetsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sessionId: sessionId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<WorkoutSet>> createElement() {
    return _SessionSetsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionSetsProvider && other.sessionId == sessionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sessionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SessionSetsRef on AutoDisposeFutureProviderRef<List<WorkoutSet>> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;
}

class _SessionSetsProviderElement
    extends AutoDisposeFutureProviderElement<List<WorkoutSet>>
    with SessionSetsRef {
  _SessionSetsProviderElement(super.provider);

  @override
  int get sessionId => (origin as SessionSetsProvider).sessionId;
}

String _$sessionExerciseInfoHash() =>
    r'f1d9b145ecc245f589c46ed1f8f3a32f45b50133';

/// See also [sessionExerciseInfo].
@ProviderFor(sessionExerciseInfo)
const sessionExerciseInfoProvider = SessionExerciseInfoFamily();

/// See also [sessionExerciseInfo].
class SessionExerciseInfoFamily extends Family<AsyncValue<Map<int, Exercise>>> {
  /// See also [sessionExerciseInfo].
  const SessionExerciseInfoFamily();

  /// See also [sessionExerciseInfo].
  SessionExerciseInfoProvider call(
    int sessionId,
  ) {
    return SessionExerciseInfoProvider(
      sessionId,
    );
  }

  @override
  SessionExerciseInfoProvider getProviderOverride(
    covariant SessionExerciseInfoProvider provider,
  ) {
    return call(
      provider.sessionId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sessionExerciseInfoProvider';
}

/// See also [sessionExerciseInfo].
class SessionExerciseInfoProvider
    extends AutoDisposeFutureProvider<Map<int, Exercise>> {
  /// See also [sessionExerciseInfo].
  SessionExerciseInfoProvider(
    int sessionId,
  ) : this._internal(
          (ref) => sessionExerciseInfo(
            ref as SessionExerciseInfoRef,
            sessionId,
          ),
          from: sessionExerciseInfoProvider,
          name: r'sessionExerciseInfoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionExerciseInfoHash,
          dependencies: SessionExerciseInfoFamily._dependencies,
          allTransitiveDependencies:
              SessionExerciseInfoFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SessionExerciseInfoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sessionId,
  }) : super.internal();

  final int sessionId;

  @override
  Override overrideWith(
    FutureOr<Map<int, Exercise>> Function(SessionExerciseInfoRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SessionExerciseInfoProvider._internal(
        (ref) => create(ref as SessionExerciseInfoRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sessionId: sessionId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<int, Exercise>> createElement() {
    return _SessionExerciseInfoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionExerciseInfoProvider && other.sessionId == sessionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sessionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SessionExerciseInfoRef
    on AutoDisposeFutureProviderRef<Map<int, Exercise>> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;
}

class _SessionExerciseInfoProviderElement
    extends AutoDisposeFutureProviderElement<Map<int, Exercise>>
    with SessionExerciseInfoRef {
  _SessionExerciseInfoProviderElement(super.provider);

  @override
  int get sessionId => (origin as SessionExerciseInfoProvider).sessionId;
}

String _$allExercisesHash() => r'0d420f4199898881291d469750335ccc9f36a5e0';

/// See also [allExercises].
@ProviderFor(allExercises)
final allExercisesProvider = AutoDisposeFutureProvider<List<Exercise>>.internal(
  allExercises,
  name: r'allExercisesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allExercisesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllExercisesRef = AutoDisposeFutureProviderRef<List<Exercise>>;
String _$exerciseAlternativesHash() =>
    r'b9b019f4da080df8b7d962b0dc49a04837755143';

/// See also [exerciseAlternatives].
@ProviderFor(exerciseAlternatives)
const exerciseAlternativesProvider = ExerciseAlternativesFamily();

/// See also [exerciseAlternatives].
class ExerciseAlternativesFamily extends Family<AsyncValue<List<Exercise>>> {
  /// See also [exerciseAlternatives].
  const ExerciseAlternativesFamily();

  /// See also [exerciseAlternatives].
  ExerciseAlternativesProvider call(
    int exerciseId,
  ) {
    return ExerciseAlternativesProvider(
      exerciseId,
    );
  }

  @override
  ExerciseAlternativesProvider getProviderOverride(
    covariant ExerciseAlternativesProvider provider,
  ) {
    return call(
      provider.exerciseId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'exerciseAlternativesProvider';
}

/// See also [exerciseAlternatives].
class ExerciseAlternativesProvider
    extends AutoDisposeFutureProvider<List<Exercise>> {
  /// See also [exerciseAlternatives].
  ExerciseAlternativesProvider(
    int exerciseId,
  ) : this._internal(
          (ref) => exerciseAlternatives(
            ref as ExerciseAlternativesRef,
            exerciseId,
          ),
          from: exerciseAlternativesProvider,
          name: r'exerciseAlternativesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$exerciseAlternativesHash,
          dependencies: ExerciseAlternativesFamily._dependencies,
          allTransitiveDependencies:
              ExerciseAlternativesFamily._allTransitiveDependencies,
          exerciseId: exerciseId,
        );

  ExerciseAlternativesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.exerciseId,
  }) : super.internal();

  final int exerciseId;

  @override
  Override overrideWith(
    FutureOr<List<Exercise>> Function(ExerciseAlternativesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ExerciseAlternativesProvider._internal(
        (ref) => create(ref as ExerciseAlternativesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        exerciseId: exerciseId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Exercise>> createElement() {
    return _ExerciseAlternativesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExerciseAlternativesProvider &&
        other.exerciseId == exerciseId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, exerciseId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ExerciseAlternativesRef on AutoDisposeFutureProviderRef<List<Exercise>> {
  /// The parameter `exerciseId` of this provider.
  int get exerciseId;
}

class _ExerciseAlternativesProviderElement
    extends AutoDisposeFutureProviderElement<List<Exercise>>
    with ExerciseAlternativesRef {
  _ExerciseAlternativesProviderElement(super.provider);

  @override
  int get exerciseId => (origin as ExerciseAlternativesProvider).exerciseId;
}

String _$routineListHash() => r'1ab89a1b0300edd89c3b0980b8d91f8e00e1b8da';

/// See also [routineList].
@ProviderFor(routineList)
final routineListProvider =
    AutoDisposeFutureProvider<List<RoutineSummary>>.internal(
  routineList,
  name: r'routineListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$routineListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RoutineListRef = AutoDisposeFutureProviderRef<List<RoutineSummary>>;
String _$routineExercisesHash() => r'9b0cd9b611bffe533335b8f2a3004b1ec547d3c1';

/// See also [routineExercises].
@ProviderFor(routineExercises)
const routineExercisesProvider = RoutineExercisesFamily();

/// See also [routineExercises].
class RoutineExercisesFamily
    extends Family<AsyncValue<List<RoutineExerciseDetail>>> {
  /// See also [routineExercises].
  const RoutineExercisesFamily();

  /// See also [routineExercises].
  RoutineExercisesProvider call(
    int routineId,
  ) {
    return RoutineExercisesProvider(
      routineId,
    );
  }

  @override
  RoutineExercisesProvider getProviderOverride(
    covariant RoutineExercisesProvider provider,
  ) {
    return call(
      provider.routineId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'routineExercisesProvider';
}

/// See also [routineExercises].
class RoutineExercisesProvider
    extends AutoDisposeFutureProvider<List<RoutineExerciseDetail>> {
  /// See also [routineExercises].
  RoutineExercisesProvider(
    int routineId,
  ) : this._internal(
          (ref) => routineExercises(
            ref as RoutineExercisesRef,
            routineId,
          ),
          from: routineExercisesProvider,
          name: r'routineExercisesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$routineExercisesHash,
          dependencies: RoutineExercisesFamily._dependencies,
          allTransitiveDependencies:
              RoutineExercisesFamily._allTransitiveDependencies,
          routineId: routineId,
        );

  RoutineExercisesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.routineId,
  }) : super.internal();

  final int routineId;

  @override
  Override overrideWith(
    FutureOr<List<RoutineExerciseDetail>> Function(RoutineExercisesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoutineExercisesProvider._internal(
        (ref) => create(ref as RoutineExercisesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        routineId: routineId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<RoutineExerciseDetail>>
      createElement() {
    return _RoutineExercisesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoutineExercisesProvider && other.routineId == routineId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, routineId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RoutineExercisesRef
    on AutoDisposeFutureProviderRef<List<RoutineExerciseDetail>> {
  /// The parameter `routineId` of this provider.
  int get routineId;
}

class _RoutineExercisesProviderElement
    extends AutoDisposeFutureProviderElement<List<RoutineExerciseDetail>>
    with RoutineExercisesRef {
  _RoutineExercisesProviderElement(super.provider);

  @override
  int get routineId => (origin as RoutineExercisesProvider).routineId;
}

String _$bodyPartsHash() => r'22a05fc8b66c8b0a03062c8c4c8ce0cb4d7616b9';

/// See also [bodyParts].
@ProviderFor(bodyParts)
final bodyPartsProvider = AutoDisposeFutureProvider<List<String>>.internal(
  bodyParts,
  name: r'bodyPartsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$bodyPartsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BodyPartsRef = AutoDisposeFutureProviderRef<List<String>>;
String _$weeklyStatsHash() => r'fc227b8b998396f2ad857b3c341d494607f62eae';

/// See also [weeklyStats].
@ProviderFor(weeklyStats)
final weeklyStatsProvider = AutoDisposeFutureProvider<WeeklyStats>.internal(
  weeklyStats,
  name: r'weeklyStatsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$weeklyStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeeklyStatsRef = AutoDisposeFutureProviderRef<WeeklyStats>;
String _$weeklyVolumeChartHash() => r'cb303374f0e4af0d2c32ca7a56b32b2fdb27930a';

/// See also [weeklyVolumeChart].
@ProviderFor(weeklyVolumeChart)
final weeklyVolumeChartProvider =
    AutoDisposeFutureProvider<List<double>>.internal(
  weeklyVolumeChart,
  name: r'weeklyVolumeChartProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$weeklyVolumeChartHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeeklyVolumeChartRef = AutoDisposeFutureProviderRef<List<double>>;
String _$recentSessionsHash() => r'8f26076e5a50d650dc46a5d7046b60f04762b5c1';

/// See also [recentSessions].
@ProviderFor(recentSessions)
final recentSessionsProvider =
    AutoDisposeFutureProvider<List<WorkoutSessionSummary>>.internal(
  recentSessions,
  name: r'recentSessionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentSessionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentSessionsRef
    = AutoDisposeFutureProviderRef<List<WorkoutSessionSummary>>;
String _$lastRoutineHash() => r'8a238389c8def607233e994007c175f04af2f311';

/// See also [lastRoutine].
@ProviderFor(lastRoutine)
final lastRoutineProvider = AutoDisposeFutureProvider<RoutineSummary?>.internal(
  lastRoutine,
  name: r'lastRoutineProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$lastRoutineHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LastRoutineRef = AutoDisposeFutureProviderRef<RoutineSummary?>;
String _$workoutSessionNotifierHash() =>
    r'330f3b5445631ea3b2b74499179ec69e1c4f184a';

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
