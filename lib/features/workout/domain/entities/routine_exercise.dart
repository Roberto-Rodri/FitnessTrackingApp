import 'package:freezed_annotation/freezed_annotation.dart';

part 'routine_exercise.freezed.dart';
part 'routine_exercise.g.dart';

@freezed
class RoutineExercise with _$RoutineExercise {
  const factory RoutineExercise({
    required int routineId,
    required int exerciseId,
    required int sequenceOrder,
    required int targetSets,
    required String targetReps,
    @Default(90) int restSeconds,
  }) = _RoutineExercise;

  factory RoutineExercise.fromJson(Map<String, dynamic> json) => _$RoutineExerciseFromJson(json);
}
