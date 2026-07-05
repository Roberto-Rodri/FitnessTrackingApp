import 'package:freezed_annotation/freezed_annotation.dart';

part 'routine_exercise_detail.freezed.dart';
part 'routine_exercise_detail.g.dart';

@freezed
class RoutineExerciseDetail with _$RoutineExerciseDetail {
  const factory RoutineExerciseDetail({
    required int exerciseId,
    required String exerciseName,
    required String bodyPart,
    required int sequenceOrder,
    required int targetSets,
    required String targetReps,
    @Default(90) int restSeconds,
    @Default('kg') String weightUnit,
    int? supersetGroup,
  }) = _RoutineExerciseDetail;

  factory RoutineExerciseDetail.fromJson(Map<String, dynamic> json) =>
      _$RoutineExerciseDetailFromJson(json);
}
