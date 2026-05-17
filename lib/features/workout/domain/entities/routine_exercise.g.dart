// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoutineExerciseImpl _$$RoutineExerciseImplFromJson(
        Map<String, dynamic> json) =>
    _$RoutineExerciseImpl(
      routineId: (json['routineId'] as num).toInt(),
      exerciseId: (json['exerciseId'] as num).toInt(),
      sequenceOrder: (json['sequenceOrder'] as num).toInt(),
      targetSets: (json['targetSets'] as num).toInt(),
      targetReps: json['targetReps'] as String,
      restSeconds: (json['restSeconds'] as num?)?.toInt() ?? 90,
    );

Map<String, dynamic> _$$RoutineExerciseImplToJson(
        _$RoutineExerciseImpl instance) =>
    <String, dynamic>{
      'routineId': instance.routineId,
      'exerciseId': instance.exerciseId,
      'sequenceOrder': instance.sequenceOrder,
      'targetSets': instance.targetSets,
      'targetReps': instance.targetReps,
      'restSeconds': instance.restSeconds,
    };
