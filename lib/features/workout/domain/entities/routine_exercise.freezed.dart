// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routine_exercise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RoutineExercise _$RoutineExerciseFromJson(Map<String, dynamic> json) {
  return _RoutineExercise.fromJson(json);
}

/// @nodoc
mixin _$RoutineExercise {
  int get routineId => throw _privateConstructorUsedError;
  int get exerciseId => throw _privateConstructorUsedError;
  int get sequenceOrder => throw _privateConstructorUsedError;
  int get targetSets => throw _privateConstructorUsedError;
  String get targetReps => throw _privateConstructorUsedError;
  int get restSeconds => throw _privateConstructorUsedError;
  int? get supersetGroup => throw _privateConstructorUsedError;

  /// Serializes this RoutineExercise to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoutineExercise
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoutineExerciseCopyWith<RoutineExercise> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoutineExerciseCopyWith<$Res> {
  factory $RoutineExerciseCopyWith(
          RoutineExercise value, $Res Function(RoutineExercise) then) =
      _$RoutineExerciseCopyWithImpl<$Res, RoutineExercise>;
  @useResult
  $Res call(
      {int routineId,
      int exerciseId,
      int sequenceOrder,
      int targetSets,
      String targetReps,
      int restSeconds,
      int? supersetGroup});
}

/// @nodoc
class _$RoutineExerciseCopyWithImpl<$Res, $Val extends RoutineExercise>
    implements $RoutineExerciseCopyWith<$Res> {
  _$RoutineExerciseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoutineExercise
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? routineId = null,
    Object? exerciseId = null,
    Object? sequenceOrder = null,
    Object? targetSets = null,
    Object? targetReps = null,
    Object? restSeconds = null,
    Object? supersetGroup = freezed,
  }) {
    return _then(_value.copyWith(
      routineId: null == routineId
          ? _value.routineId
          : routineId // ignore: cast_nullable_to_non_nullable
              as int,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as int,
      sequenceOrder: null == sequenceOrder
          ? _value.sequenceOrder
          : sequenceOrder // ignore: cast_nullable_to_non_nullable
              as int,
      targetSets: null == targetSets
          ? _value.targetSets
          : targetSets // ignore: cast_nullable_to_non_nullable
              as int,
      targetReps: null == targetReps
          ? _value.targetReps
          : targetReps // ignore: cast_nullable_to_non_nullable
              as String,
      restSeconds: null == restSeconds
          ? _value.restSeconds
          : restSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      supersetGroup: freezed == supersetGroup
          ? _value.supersetGroup
          : supersetGroup // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoutineExerciseImplCopyWith<$Res>
    implements $RoutineExerciseCopyWith<$Res> {
  factory _$$RoutineExerciseImplCopyWith(_$RoutineExerciseImpl value,
          $Res Function(_$RoutineExerciseImpl) then) =
      __$$RoutineExerciseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int routineId,
      int exerciseId,
      int sequenceOrder,
      int targetSets,
      String targetReps,
      int restSeconds,
      int? supersetGroup});
}

/// @nodoc
class __$$RoutineExerciseImplCopyWithImpl<$Res>
    extends _$RoutineExerciseCopyWithImpl<$Res, _$RoutineExerciseImpl>
    implements _$$RoutineExerciseImplCopyWith<$Res> {
  __$$RoutineExerciseImplCopyWithImpl(
      _$RoutineExerciseImpl _value, $Res Function(_$RoutineExerciseImpl) _then)
      : super(_value, _then);

  /// Create a copy of RoutineExercise
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? routineId = null,
    Object? exerciseId = null,
    Object? sequenceOrder = null,
    Object? targetSets = null,
    Object? targetReps = null,
    Object? restSeconds = null,
    Object? supersetGroup = freezed,
  }) {
    return _then(_$RoutineExerciseImpl(
      routineId: null == routineId
          ? _value.routineId
          : routineId // ignore: cast_nullable_to_non_nullable
              as int,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as int,
      sequenceOrder: null == sequenceOrder
          ? _value.sequenceOrder
          : sequenceOrder // ignore: cast_nullable_to_non_nullable
              as int,
      targetSets: null == targetSets
          ? _value.targetSets
          : targetSets // ignore: cast_nullable_to_non_nullable
              as int,
      targetReps: null == targetReps
          ? _value.targetReps
          : targetReps // ignore: cast_nullable_to_non_nullable
              as String,
      restSeconds: null == restSeconds
          ? _value.restSeconds
          : restSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      supersetGroup: freezed == supersetGroup
          ? _value.supersetGroup
          : supersetGroup // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoutineExerciseImpl implements _RoutineExercise {
  const _$RoutineExerciseImpl(
      {required this.routineId,
      required this.exerciseId,
      required this.sequenceOrder,
      required this.targetSets,
      required this.targetReps,
      this.restSeconds = 90,
      this.supersetGroup});

  factory _$RoutineExerciseImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoutineExerciseImplFromJson(json);

  @override
  final int routineId;
  @override
  final int exerciseId;
  @override
  final int sequenceOrder;
  @override
  final int targetSets;
  @override
  final String targetReps;
  @override
  @JsonKey()
  final int restSeconds;
  @override
  final int? supersetGroup;

  @override
  String toString() {
    return 'RoutineExercise(routineId: $routineId, exerciseId: $exerciseId, sequenceOrder: $sequenceOrder, targetSets: $targetSets, targetReps: $targetReps, restSeconds: $restSeconds, supersetGroup: $supersetGroup)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoutineExerciseImpl &&
            (identical(other.routineId, routineId) ||
                other.routineId == routineId) &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.sequenceOrder, sequenceOrder) ||
                other.sequenceOrder == sequenceOrder) &&
            (identical(other.targetSets, targetSets) ||
                other.targetSets == targetSets) &&
            (identical(other.targetReps, targetReps) ||
                other.targetReps == targetReps) &&
            (identical(other.restSeconds, restSeconds) ||
                other.restSeconds == restSeconds) &&
            (identical(other.supersetGroup, supersetGroup) ||
                other.supersetGroup == supersetGroup));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, routineId, exerciseId,
      sequenceOrder, targetSets, targetReps, restSeconds, supersetGroup);

  /// Create a copy of RoutineExercise
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoutineExerciseImplCopyWith<_$RoutineExerciseImpl> get copyWith =>
      __$$RoutineExerciseImplCopyWithImpl<_$RoutineExerciseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoutineExerciseImplToJson(
      this,
    );
  }
}

abstract class _RoutineExercise implements RoutineExercise {
  const factory _RoutineExercise(
      {required final int routineId,
      required final int exerciseId,
      required final int sequenceOrder,
      required final int targetSets,
      required final String targetReps,
      final int restSeconds,
      final int? supersetGroup}) = _$RoutineExerciseImpl;

  factory _RoutineExercise.fromJson(Map<String, dynamic> json) =
      _$RoutineExerciseImpl.fromJson;

  @override
  int get routineId;
  @override
  int get exerciseId;
  @override
  int get sequenceOrder;
  @override
  int get targetSets;
  @override
  String get targetReps;
  @override
  int get restSeconds;
  @override
  int? get supersetGroup;

  /// Create a copy of RoutineExercise
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoutineExerciseImplCopyWith<_$RoutineExerciseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
