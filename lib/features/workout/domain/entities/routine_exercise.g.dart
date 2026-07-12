// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RoutineExercise _$RoutineExerciseFromJson(Map<String, dynamic> json) =>
    _RoutineExercise(
      routineId: (json['routineId'] as num).toInt(),
      exerciseId: (json['exerciseId'] as num).toInt(),
      sequenceOrder: (json['sequenceOrder'] as num).toInt(),
      targetSets: (json['targetSets'] as num).toInt(),
      targetReps: json['targetReps'] as String,
      supersetGroup: (json['supersetGroup'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RoutineExerciseToJson(_RoutineExercise instance) =>
    <String, dynamic>{
      'routineId': instance.routineId,
      'exerciseId': instance.exerciseId,
      'sequenceOrder': instance.sequenceOrder,
      'targetSets': instance.targetSets,
      'targetReps': instance.targetReps,
      'supersetGroup': instance.supersetGroup,
    };
