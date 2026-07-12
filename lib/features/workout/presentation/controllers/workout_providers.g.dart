// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UseRoutineLatestNotifier)
final useRoutineLatestProvider = UseRoutineLatestNotifierProvider._();

final class UseRoutineLatestNotifierProvider
    extends $NotifierProvider<UseRoutineLatestNotifier, bool> {
  UseRoutineLatestNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'useRoutineLatestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$useRoutineLatestNotifierHash();

  @$internal
  @override
  UseRoutineLatestNotifier create() => UseRoutineLatestNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$useRoutineLatestNotifierHash() =>
    r'67ca0b494c51aefad56247118437e1933fcfbceb';

abstract class _$UseRoutineLatestNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(sessionPRCount)
final sessionPRCountProvider = SessionPRCountFamily._();

final class SessionPRCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  SessionPRCountProvider._({
    required SessionPRCountFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'sessionPRCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sessionPRCountHash();

  @override
  String toString() {
    return r'sessionPRCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as int;
    return sessionPRCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionPRCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionPRCountHash() => r'695f1ac078d10698930eb0fd4afa0b97e2dc7dd9';

final class SessionPRCountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, int> {
  SessionPRCountFamily._()
    : super(
        retry: null,
        name: r'sessionPRCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SessionPRCountProvider call(int sessionId) =>
      SessionPRCountProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'sessionPRCountProvider';
}

@ProviderFor(completedSessions)
final completedSessionsProvider = CompletedSessionsProvider._();

final class CompletedSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutSessionSummary>>,
          List<WorkoutSessionSummary>,
          FutureOr<List<WorkoutSessionSummary>>
        >
    with
        $FutureModifier<List<WorkoutSessionSummary>>,
        $FutureProvider<List<WorkoutSessionSummary>> {
  CompletedSessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'completedSessionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$completedSessionsHash();

  @$internal
  @override
  $FutureProviderElement<List<WorkoutSessionSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkoutSessionSummary>> create(Ref ref) {
    return completedSessions(ref);
  }
}

String _$completedSessionsHash() => r'8bec9b7d4ebb1d1330da4e7042eb0cec67b6acad';

@ProviderFor(HistoryFilterNotifier)
final historyFilterProvider = HistoryFilterNotifierProvider._();

final class HistoryFilterNotifierProvider
    extends $NotifierProvider<HistoryFilterNotifier, HistoryFilter> {
  HistoryFilterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyFilterNotifierHash();

  @$internal
  @override
  HistoryFilterNotifier create() => HistoryFilterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HistoryFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HistoryFilter>(value),
    );
  }
}

String _$historyFilterNotifierHash() =>
    r'3f94f725cfccefe4ff310e69eefea97d58896cfb';

abstract class _$HistoryFilterNotifier extends $Notifier<HistoryFilter> {
  HistoryFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<HistoryFilter, HistoryFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HistoryFilter, HistoryFilter>,
              HistoryFilter,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredSessions)
final filteredSessionsProvider = FilteredSessionsProvider._();

final class FilteredSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutSessionSummary>>,
          List<WorkoutSessionSummary>,
          FutureOr<List<WorkoutSessionSummary>>
        >
    with
        $FutureModifier<List<WorkoutSessionSummary>>,
        $FutureProvider<List<WorkoutSessionSummary>> {
  FilteredSessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredSessionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredSessionsHash();

  @$internal
  @override
  $FutureProviderElement<List<WorkoutSessionSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkoutSessionSummary>> create(Ref ref) {
    return filteredSessions(ref);
  }
}

String _$filteredSessionsHash() => r'f00e7a5121526041c6155c1fb150525ea4464fd8';

@ProviderFor(sessionSets)
final sessionSetsProvider = SessionSetsFamily._();

final class SessionSetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutSet>>,
          List<WorkoutSet>,
          FutureOr<List<WorkoutSet>>
        >
    with $FutureModifier<List<WorkoutSet>>, $FutureProvider<List<WorkoutSet>> {
  SessionSetsProvider._({
    required SessionSetsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'sessionSetsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sessionSetsHash();

  @override
  String toString() {
    return r'sessionSetsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<WorkoutSet>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkoutSet>> create(Ref ref) {
    final argument = this.argument as int;
    return sessionSets(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionSetsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionSetsHash() => r'15dfa305ca4352f1022a2913dbabb579a2e748e7';

final class SessionSetsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<WorkoutSet>>, int> {
  SessionSetsFamily._()
    : super(
        retry: null,
        name: r'sessionSetsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SessionSetsProvider call(int sessionId) =>
      SessionSetsProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'sessionSetsProvider';
}

@ProviderFor(sessionExerciseInfo)
final sessionExerciseInfoProvider = SessionExerciseInfoFamily._();

final class SessionExerciseInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<int, Exercise>>,
          Map<int, Exercise>,
          FutureOr<Map<int, Exercise>>
        >
    with
        $FutureModifier<Map<int, Exercise>>,
        $FutureProvider<Map<int, Exercise>> {
  SessionExerciseInfoProvider._({
    required SessionExerciseInfoFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'sessionExerciseInfoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sessionExerciseInfoHash();

  @override
  String toString() {
    return r'sessionExerciseInfoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<int, Exercise>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<int, Exercise>> create(Ref ref) {
    final argument = this.argument as int;
    return sessionExerciseInfo(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionExerciseInfoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionExerciseInfoHash() =>
    r'fa70d9b1a97de0aad0e8afb02b7f5ea5175fb5db';

final class SessionExerciseInfoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<int, Exercise>>, int> {
  SessionExerciseInfoFamily._()
    : super(
        retry: null,
        name: r'sessionExerciseInfoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SessionExerciseInfoProvider call(int sessionId) =>
      SessionExerciseInfoProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'sessionExerciseInfoProvider';
}

@ProviderFor(allExercises)
final allExercisesProvider = AllExercisesProvider._();

final class AllExercisesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Exercise>>,
          List<Exercise>,
          FutureOr<List<Exercise>>
        >
    with $FutureModifier<List<Exercise>>, $FutureProvider<List<Exercise>> {
  AllExercisesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allExercisesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allExercisesHash();

  @$internal
  @override
  $FutureProviderElement<List<Exercise>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Exercise>> create(Ref ref) {
    return allExercises(ref);
  }
}

String _$allExercisesHash() => r'fbff13aab1b10a123e7a35a02862e4c2eafd54d9';

@ProviderFor(exerciseAlternatives)
final exerciseAlternativesProvider = ExerciseAlternativesFamily._();

final class ExerciseAlternativesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Exercise>>,
          List<Exercise>,
          FutureOr<List<Exercise>>
        >
    with $FutureModifier<List<Exercise>>, $FutureProvider<List<Exercise>> {
  ExerciseAlternativesProvider._({
    required ExerciseAlternativesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'exerciseAlternativesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exerciseAlternativesHash();

  @override
  String toString() {
    return r'exerciseAlternativesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Exercise>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Exercise>> create(Ref ref) {
    final argument = this.argument as int;
    return exerciseAlternatives(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExerciseAlternativesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exerciseAlternativesHash() =>
    r'd6b5c9ed8ee69722d0747dd0116bea4746fdced6';

final class ExerciseAlternativesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Exercise>>, int> {
  ExerciseAlternativesFamily._()
    : super(
        retry: null,
        name: r'exerciseAlternativesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExerciseAlternativesProvider call(int exerciseId) =>
      ExerciseAlternativesProvider._(argument: exerciseId, from: this);

  @override
  String toString() => r'exerciseAlternativesProvider';
}

@ProviderFor(routineList)
final routineListProvider = RoutineListProvider._();

final class RoutineListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RoutineSummary>>,
          List<RoutineSummary>,
          FutureOr<List<RoutineSummary>>
        >
    with
        $FutureModifier<List<RoutineSummary>>,
        $FutureProvider<List<RoutineSummary>> {
  RoutineListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routineListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routineListHash();

  @$internal
  @override
  $FutureProviderElement<List<RoutineSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RoutineSummary>> create(Ref ref) {
    return routineList(ref);
  }
}

String _$routineListHash() => r'736ae0346b8322bc1da51eaea5808b188dcf2dc0';

@ProviderFor(routineExercises)
final routineExercisesProvider = RoutineExercisesFamily._();

final class RoutineExercisesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RoutineExerciseDetail>>,
          List<RoutineExerciseDetail>,
          FutureOr<List<RoutineExerciseDetail>>
        >
    with
        $FutureModifier<List<RoutineExerciseDetail>>,
        $FutureProvider<List<RoutineExerciseDetail>> {
  RoutineExercisesProvider._({
    required RoutineExercisesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'routineExercisesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$routineExercisesHash();

  @override
  String toString() {
    return r'routineExercisesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<RoutineExerciseDetail>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RoutineExerciseDetail>> create(Ref ref) {
    final argument = this.argument as int;
    return routineExercises(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RoutineExercisesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$routineExercisesHash() => r'43c10364e555b293a04bc748d73c9fcd71f705f1';

final class RoutineExercisesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<RoutineExerciseDetail>>, int> {
  RoutineExercisesFamily._()
    : super(
        retry: null,
        name: r'routineExercisesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RoutineExercisesProvider call(int routineId) =>
      RoutineExercisesProvider._(argument: routineId, from: this);

  @override
  String toString() => r'routineExercisesProvider';
}

@ProviderFor(bodyParts)
final bodyPartsProvider = BodyPartsProvider._();

final class BodyPartsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  BodyPartsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bodyPartsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bodyPartsHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return bodyParts(ref);
  }
}

String _$bodyPartsHash() => r'f04e0b641bcb20fdf93e106712982395bb73a649';

@ProviderFor(weeklyStats)
final weeklyStatsProvider = WeeklyStatsProvider._();

final class WeeklyStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<WeeklyStats>,
          WeeklyStats,
          FutureOr<WeeklyStats>
        >
    with $FutureModifier<WeeklyStats>, $FutureProvider<WeeklyStats> {
  WeeklyStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weeklyStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weeklyStatsHash();

  @$internal
  @override
  $FutureProviderElement<WeeklyStats> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WeeklyStats> create(Ref ref) {
    return weeklyStats(ref);
  }
}

String _$weeklyStatsHash() => r'dd2a5998e0a1acf7f1488226450fb68b2e3d4821';

@ProviderFor(weeklyVolumeChart)
final weeklyVolumeChartProvider = WeeklyVolumeChartProvider._();

final class WeeklyVolumeChartProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<double>>,
          List<double>,
          FutureOr<List<double>>
        >
    with $FutureModifier<List<double>>, $FutureProvider<List<double>> {
  WeeklyVolumeChartProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weeklyVolumeChartProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weeklyVolumeChartHash();

  @$internal
  @override
  $FutureProviderElement<List<double>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<double>> create(Ref ref) {
    return weeklyVolumeChart(ref);
  }
}

String _$weeklyVolumeChartHash() => r'47f3aa0dbe63877b2d7c68b7325cdc7a3296897d';

@ProviderFor(recentSessions)
final recentSessionsProvider = RecentSessionsProvider._();

final class RecentSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutSessionSummary>>,
          List<WorkoutSessionSummary>,
          FutureOr<List<WorkoutSessionSummary>>
        >
    with
        $FutureModifier<List<WorkoutSessionSummary>>,
        $FutureProvider<List<WorkoutSessionSummary>> {
  RecentSessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentSessionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentSessionsHash();

  @$internal
  @override
  $FutureProviderElement<List<WorkoutSessionSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkoutSessionSummary>> create(Ref ref) {
    return recentSessions(ref);
  }
}

String _$recentSessionsHash() => r'ea4e7818163300a115cb120575010b2206f02d90';

@ProviderFor(lastRoutine)
final lastRoutineProvider = LastRoutineProvider._();

final class LastRoutineProvider
    extends
        $FunctionalProvider<
          AsyncValue<RoutineSummary?>,
          RoutineSummary?,
          FutureOr<RoutineSummary?>
        >
    with $FutureModifier<RoutineSummary?>, $FutureProvider<RoutineSummary?> {
  LastRoutineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastRoutineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastRoutineHash();

  @$internal
  @override
  $FutureProviderElement<RoutineSummary?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RoutineSummary?> create(Ref ref) {
    return lastRoutine(ref);
  }
}

String _$lastRoutineHash() => r'b57038909826ab77735856cf4bed7df8bc7c0f35';

@ProviderFor(ShowConfettiNotifier)
final showConfettiProvider = ShowConfettiNotifierProvider._();

final class ShowConfettiNotifierProvider
    extends $NotifierProvider<ShowConfettiNotifier, bool> {
  ShowConfettiNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showConfettiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showConfettiNotifierHash();

  @$internal
  @override
  ShowConfettiNotifier create() => ShowConfettiNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showConfettiNotifierHash() =>
    r'cb859e07767cbe095c8bfb9ed8e8c31bcabbb8d5';

abstract class _$ShowConfettiNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(previousSession)
final previousSessionProvider = PreviousSessionFamily._();

final class PreviousSessionProvider
    extends
        $FunctionalProvider<
          AsyncValue<WorkoutSessionSummary?>,
          WorkoutSessionSummary?,
          FutureOr<WorkoutSessionSummary?>
        >
    with
        $FutureModifier<WorkoutSessionSummary?>,
        $FutureProvider<WorkoutSessionSummary?> {
  PreviousSessionProvider._({
    required PreviousSessionFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'previousSessionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$previousSessionHash();

  @override
  String toString() {
    return r'previousSessionProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<WorkoutSessionSummary?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WorkoutSessionSummary?> create(Ref ref) {
    final argument = this.argument as (int, int);
    return previousSession(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is PreviousSessionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$previousSessionHash() => r'323f7e024819fe1f8ad9363c1a18453df03c24b1';

final class PreviousSessionFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<WorkoutSessionSummary?>,
          (int, int)
        > {
  PreviousSessionFamily._()
    : super(
        retry: null,
        name: r'previousSessionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PreviousSessionProvider call(int routineId, int currentSessionId) =>
      PreviousSessionProvider._(
        argument: (routineId, currentSessionId),
        from: this,
      );

  @override
  String toString() => r'previousSessionProvider';
}

@ProviderFor(WorkoutSessionController)
final workoutSessionControllerProvider = WorkoutSessionControllerProvider._();

final class WorkoutSessionControllerProvider
    extends
        $AsyncNotifierProvider<WorkoutSessionController, ActiveWorkoutState> {
  WorkoutSessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutSessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutSessionControllerHash();

  @$internal
  @override
  WorkoutSessionController create() => WorkoutSessionController();
}

String _$workoutSessionControllerHash() =>
    r'6bebda44168b02387039a905bea830f3706ca1a7';

abstract class _$WorkoutSessionController
    extends $AsyncNotifier<ActiveWorkoutState> {
  FutureOr<ActiveWorkoutState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ActiveWorkoutState>, ActiveWorkoutState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ActiveWorkoutState>, ActiveWorkoutState>,
              AsyncValue<ActiveWorkoutState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(exerciseHistory)
final exerciseHistoryProvider = ExerciseHistoryFamily._();

final class ExerciseHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ExerciseHistorySummary>,
          ExerciseHistorySummary,
          FutureOr<ExerciseHistorySummary>
        >
    with
        $FutureModifier<ExerciseHistorySummary>,
        $FutureProvider<ExerciseHistorySummary> {
  ExerciseHistoryProvider._({
    required ExerciseHistoryFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'exerciseHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exerciseHistoryHash();

  @override
  String toString() {
    return r'exerciseHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ExerciseHistorySummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ExerciseHistorySummary> create(Ref ref) {
    final argument = this.argument as int;
    return exerciseHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExerciseHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exerciseHistoryHash() => r'cf0a71f8faa95ce897310d61e24fb4724ff04d32';

final class ExerciseHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ExerciseHistorySummary>, int> {
  ExerciseHistoryFamily._()
    : super(
        retry: null,
        name: r'exerciseHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExerciseHistoryProvider call(int exerciseId) =>
      ExerciseHistoryProvider._(argument: exerciseId, from: this);

  @override
  String toString() => r'exerciseHistoryProvider';
}

@ProviderFor(workoutSummary)
final workoutSummaryProvider = WorkoutSummaryFamily._();

final class WorkoutSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<WorkoutSummaryDetail>,
          WorkoutSummaryDetail,
          FutureOr<WorkoutSummaryDetail>
        >
    with
        $FutureModifier<WorkoutSummaryDetail>,
        $FutureProvider<WorkoutSummaryDetail> {
  WorkoutSummaryProvider._({
    required WorkoutSummaryFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'workoutSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workoutSummaryHash();

  @override
  String toString() {
    return r'workoutSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<WorkoutSummaryDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WorkoutSummaryDetail> create(Ref ref) {
    final argument = this.argument as int;
    return workoutSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkoutSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workoutSummaryHash() => r'5a9bc5985f3dd93b37374b8842815c56e7e59fed';

final class WorkoutSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<WorkoutSummaryDetail>, int> {
  WorkoutSummaryFamily._()
    : super(
        retry: null,
        name: r'workoutSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WorkoutSummaryProvider call(int sessionId) =>
      WorkoutSummaryProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'workoutSummaryProvider';
}
