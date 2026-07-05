// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutSessionImpl _$$WorkoutSessionImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutSessionImpl(
      id: (json['id'] as num?)?.toInt(),
      startTimestamp: (json['startTimestamp'] as num).toInt(),
      endTimestamp: (json['endTimestamp'] as num?)?.toInt(),
      routineId: (json['routineId'] as num?)?.toInt(),
      routineNameSnapshot: json['routineNameSnapshot'] as String,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$WorkoutSessionImplToJson(
        _$WorkoutSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startTimestamp': instance.startTimestamp,
      'endTimestamp': instance.endTimestamp,
      'routineId': instance.routineId,
      'routineNameSnapshot': instance.routineNameSnapshot,
      'notes': instance.notes,
    };
