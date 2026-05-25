import 'package:freezed_annotation/freezed_annotation.dart';
import 'exercise.dart';
import 'workout_set.dart';
import 'workout_session.dart';

part 'exercise_history_summary.freezed.dart';
part 'exercise_history_summary.g.dart';

@freezed
class SessionVolume with _$SessionVolume {
  const factory SessionVolume({
    required int sessionId,
    required int timestamp,
    required double volume,
    required bool hasPR,
  }) = _SessionVolume;

  factory SessionVolume.fromJson(Map<String, dynamic> json) => _$SessionVolumeFromJson(json);
}

@freezed
class ExerciseHistorySummary with _$ExerciseHistorySummary {
  const factory ExerciseHistorySummary({
    required Exercise exercise,
    WorkoutSet? allTimeBest,
    @Default([]) List<SessionVolume> volumeHistory,
    @Default([]) List<WorkoutSession> recentSessions,
  }) = _ExerciseHistorySummary;

  factory ExerciseHistorySummary.fromJson(Map<String, dynamic> json) => _$ExerciseHistorySummaryFromJson(json);
}
