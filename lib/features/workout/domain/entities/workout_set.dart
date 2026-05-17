import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_set.freezed.dart';
part 'workout_set.g.dart';

bool _boolFromInt(int? value) => value == 1;
int _boolToInt(bool value) => value ? 1 : 0;

@freezed
class WorkoutSet with _$WorkoutSet {
  const factory WorkoutSet({
    int? id,
    required int sessionId,
    required int exerciseId,
    required double weight,
    required int reps,
    int? rpe,
    String? customWeight,
    @JsonKey(fromJson: _boolFromInt, toJson: _boolToInt) @Default(false) bool isWarmup,
  }) = _WorkoutSet;

  factory WorkoutSet.fromJson(Map<String, dynamic> json) => _$WorkoutSetFromJson(json);
}
