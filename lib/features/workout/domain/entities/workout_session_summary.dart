import 'package:freezed_annotation/freezed_annotation.dart';
import 'workout_session.dart';

part 'workout_session_summary.freezed.dart';

@freezed
class WorkoutSessionSummary with _$WorkoutSessionSummary {
  const factory WorkoutSessionSummary({
    required WorkoutSession session,
    required int totalSets,
    required double totalVolume,
  }) = _WorkoutSessionSummary;
}
