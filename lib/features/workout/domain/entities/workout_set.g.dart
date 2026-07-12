// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutSet _$WorkoutSetFromJson(Map<String, dynamic> json) => _WorkoutSet(
  id: (json['id'] as num?)?.toInt(),
  sessionId: (json['sessionId'] as num).toInt(),
  exerciseId: (json['exerciseId'] as num).toInt(),
  weight: (json['weight'] as num).toDouble(),
  reps: (json['reps'] as num).toInt(),
  rpe: (json['rpe'] as num?)?.toInt(),
  customWeight: json['customWeight'] as String?,
  isWarmup: json['isWarmup'] == null
      ? false
      : _boolFromInt((json['isWarmup'] as num?)?.toInt()),
  weightUnit: json['weightUnit'] as String?,
);

Map<String, dynamic> _$WorkoutSetToJson(_WorkoutSet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'exerciseId': instance.exerciseId,
      'weight': instance.weight,
      'reps': instance.reps,
      'rpe': instance.rpe,
      'customWeight': instance.customWeight,
      'isWarmup': _boolToInt(instance.isWarmup),
      'weightUnit': instance.weightUnit,
    };
