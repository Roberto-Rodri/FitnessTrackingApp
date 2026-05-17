// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutSetImpl _$$WorkoutSetImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutSetImpl(
      id: (json['id'] as num?)?.toInt(),
      sessionId: (json['sessionId'] as num).toInt(),
      exerciseId: (json['exerciseId'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      rpe: (json['rpe'] as num?)?.toInt(),
      customWeight: json['customWeight'] as String?,
    );

Map<String, dynamic> _$$WorkoutSetImplToJson(_$WorkoutSetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'exerciseId': instance.exerciseId,
      'weight': instance.weight,
      'reps': instance.reps,
      'rpe': instance.rpe,
      'customWeight': instance.customWeight,
    };
