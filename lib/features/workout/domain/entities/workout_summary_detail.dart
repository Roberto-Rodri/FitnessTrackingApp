import 'package:freezed_annotation/freezed_annotation.dart';
import 'workout_session.dart';
import 'exercise.dart';

part 'workout_summary_detail.freezed.dart';

@freezed
class WorkoutSummaryDetail with _$WorkoutSummaryDetail {
  const factory WorkoutSummaryDetail({
    required WorkoutSession session,
    required int totalSets,
    required double totalVolume,
    required int totalPRs,
    required List<ExerciseComparison> exerciseComparisons,
  }) = _WorkoutSummaryDetail;
}

@freezed
class ExerciseComparison with _$ExerciseComparison {
  const factory ExerciseComparison({
    required Exercise exercise,
    required double currentVolume,
    required double? previousVolume,
    required int currentSets,
    required int? previousSets,
    required bool hasPR,
  }) = _ExerciseComparison;
}
