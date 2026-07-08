// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_set.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorkoutSet _$WorkoutSetFromJson(Map<String, dynamic> json) {
  return _WorkoutSet.fromJson(json);
}

/// @nodoc
mixin _$WorkoutSet {
  int? get id => throw _privateConstructorUsedError;
  int get sessionId => throw _privateConstructorUsedError;
  int get exerciseId => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;
  int get reps => throw _privateConstructorUsedError;
  int? get rpe => throw _privateConstructorUsedError;
  String? get customWeight => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _boolFromInt, toJson: _boolToInt)
  bool get isWarmup => throw _privateConstructorUsedError;
  String? get weightUnit => throw _privateConstructorUsedError;

  /// Serializes this WorkoutSet to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkoutSet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutSetCopyWith<WorkoutSet> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutSetCopyWith<$Res> {
  factory $WorkoutSetCopyWith(
          WorkoutSet value, $Res Function(WorkoutSet) then) =
      _$WorkoutSetCopyWithImpl<$Res, WorkoutSet>;
  @useResult
  $Res call(
      {int? id,
      int sessionId,
      int exerciseId,
      double weight,
      int reps,
      int? rpe,
      String? customWeight,
      @JsonKey(fromJson: _boolFromInt, toJson: _boolToInt) bool isWarmup,
      String? weightUnit});
}

/// @nodoc
class _$WorkoutSetCopyWithImpl<$Res, $Val extends WorkoutSet>
    implements $WorkoutSetCopyWith<$Res> {
  _$WorkoutSetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkoutSet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? sessionId = null,
    Object? exerciseId = null,
    Object? weight = null,
    Object? reps = null,
    Object? rpe = freezed,
    Object? customWeight = freezed,
    Object? isWarmup = null,
    Object? weightUnit = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as int,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as int,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      rpe: freezed == rpe
          ? _value.rpe
          : rpe // ignore: cast_nullable_to_non_nullable
              as int?,
      customWeight: freezed == customWeight
          ? _value.customWeight
          : customWeight // ignore: cast_nullable_to_non_nullable
              as String?,
      isWarmup: null == isWarmup
          ? _value.isWarmup
          : isWarmup // ignore: cast_nullable_to_non_nullable
              as bool,
      weightUnit: freezed == weightUnit
          ? _value.weightUnit
          : weightUnit // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutSetImplCopyWith<$Res>
    implements $WorkoutSetCopyWith<$Res> {
  factory _$$WorkoutSetImplCopyWith(
          _$WorkoutSetImpl value, $Res Function(_$WorkoutSetImpl) then) =
      __$$WorkoutSetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      int sessionId,
      int exerciseId,
      double weight,
      int reps,
      int? rpe,
      String? customWeight,
      @JsonKey(fromJson: _boolFromInt, toJson: _boolToInt) bool isWarmup,
      String? weightUnit});
}

/// @nodoc
class __$$WorkoutSetImplCopyWithImpl<$Res>
    extends _$WorkoutSetCopyWithImpl<$Res, _$WorkoutSetImpl>
    implements _$$WorkoutSetImplCopyWith<$Res> {
  __$$WorkoutSetImplCopyWithImpl(
      _$WorkoutSetImpl _value, $Res Function(_$WorkoutSetImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkoutSet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? sessionId = null,
    Object? exerciseId = null,
    Object? weight = null,
    Object? reps = null,
    Object? rpe = freezed,
    Object? customWeight = freezed,
    Object? isWarmup = null,
    Object? weightUnit = freezed,
  }) {
    return _then(_$WorkoutSetImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as int,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as int,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      rpe: freezed == rpe
          ? _value.rpe
          : rpe // ignore: cast_nullable_to_non_nullable
              as int?,
      customWeight: freezed == customWeight
          ? _value.customWeight
          : customWeight // ignore: cast_nullable_to_non_nullable
              as String?,
      isWarmup: null == isWarmup
          ? _value.isWarmup
          : isWarmup // ignore: cast_nullable_to_non_nullable
              as bool,
      weightUnit: freezed == weightUnit
          ? _value.weightUnit
          : weightUnit // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutSetImpl implements _WorkoutSet {
  const _$WorkoutSetImpl(
      {this.id,
      required this.sessionId,
      required this.exerciseId,
      required this.weight,
      required this.reps,
      this.rpe,
      this.customWeight,
      @JsonKey(fromJson: _boolFromInt, toJson: _boolToInt)
      this.isWarmup = false,
      this.weightUnit});

  factory _$WorkoutSetImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutSetImplFromJson(json);

  @override
  final int? id;
  @override
  final int sessionId;
  @override
  final int exerciseId;
  @override
  final double weight;
  @override
  final int reps;
  @override
  final int? rpe;
  @override
  final String? customWeight;
  @override
  @JsonKey(fromJson: _boolFromInt, toJson: _boolToInt)
  final bool isWarmup;
  @override
  final String? weightUnit;

  @override
  String toString() {
    return 'WorkoutSet(id: $id, sessionId: $sessionId, exerciseId: $exerciseId, weight: $weight, reps: $reps, rpe: $rpe, customWeight: $customWeight, isWarmup: $isWarmup, weightUnit: $weightUnit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutSetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.rpe, rpe) || other.rpe == rpe) &&
            (identical(other.customWeight, customWeight) ||
                other.customWeight == customWeight) &&
            (identical(other.isWarmup, isWarmup) ||
                other.isWarmup == isWarmup) &&
            (identical(other.weightUnit, weightUnit) ||
                other.weightUnit == weightUnit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, sessionId, exerciseId,
      weight, reps, rpe, customWeight, isWarmup, weightUnit);

  /// Create a copy of WorkoutSet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutSetImplCopyWith<_$WorkoutSetImpl> get copyWith =>
      __$$WorkoutSetImplCopyWithImpl<_$WorkoutSetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutSetImplToJson(
      this,
    );
  }
}

abstract class _WorkoutSet implements WorkoutSet {
  const factory _WorkoutSet(
      {final int? id,
      required final int sessionId,
      required final int exerciseId,
      required final double weight,
      required final int reps,
      final int? rpe,
      final String? customWeight,
      @JsonKey(fromJson: _boolFromInt, toJson: _boolToInt) final bool isWarmup,
      final String? weightUnit}) = _$WorkoutSetImpl;

  factory _WorkoutSet.fromJson(Map<String, dynamic> json) =
      _$WorkoutSetImpl.fromJson;

  @override
  int? get id;
  @override
  int get sessionId;
  @override
  int get exerciseId;
  @override
  double get weight;
  @override
  int get reps;
  @override
  int? get rpe;
  @override
  String? get customWeight;
  @override
  @JsonKey(fromJson: _boolFromInt, toJson: _boolToInt)
  bool get isWarmup;
  @override
  String? get weightUnit;

  /// Create a copy of WorkoutSet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutSetImplCopyWith<_$WorkoutSetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
