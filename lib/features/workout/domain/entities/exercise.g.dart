// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Exercise _$ExerciseFromJson(Map<String, dynamic> json) => _Exercise(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String,
  bodyPart: json['bodyPart'] as String,
  weightUnit: json['weightUnit'] as String? ?? 'kg',
  machineId: (json['machineId'] as num?)?.toInt(),
);

Map<String, dynamic> _$ExerciseToJson(_Exercise instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'bodyPart': instance.bodyPart,
  'weightUnit': instance.weightUnit,
  'machineId': instance.machineId,
};
