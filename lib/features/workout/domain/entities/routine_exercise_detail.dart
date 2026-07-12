import 'package:freezed_annotation/freezed_annotation.dart';

part 'routine_exercise_detail.freezed.dart';
part 'routine_exercise_detail.g.dart';

@freezed
abstract class RoutineExerciseDetail with _$RoutineExerciseDetail {
  const factory RoutineExerciseDetail({
    required int exerciseId,
    required String exerciseName,
    required String bodyPart,
    required int sequenceOrder,
    required int targetSets,
    required String targetReps,
    @Default('kg') String weightUnit,
    @Default(false) bool isSessionOnly,
    int? supersetGroup,
    int? machineId,
  }) = _RoutineExerciseDetail;

  factory RoutineExerciseDetail.fromJson(Map<String, dynamic> json) =>
      _$RoutineExerciseDetailFromJson(json);
}
