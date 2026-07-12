import 'package:freezed_annotation/freezed_annotation.dart';

part 'routine_exercise.freezed.dart';
part 'routine_exercise.g.dart';

@freezed
abstract class RoutineExercise with _$RoutineExercise {
  const factory RoutineExercise({
    required int routineId,
    required int exerciseId,
    required int sequenceOrder,
    required int targetSets,
    required String targetReps,
    int? supersetGroup,
  }) = _RoutineExercise;

  factory RoutineExercise.fromJson(Map<String, dynamic> json) => _$RoutineExerciseFromJson(json);
}
