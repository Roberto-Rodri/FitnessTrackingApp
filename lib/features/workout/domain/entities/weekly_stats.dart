import 'package:freezed_annotation/freezed_annotation.dart';

part 'weekly_stats.freezed.dart';
part 'weekly_stats.g.dart';

@freezed
class WeeklyStats with _$WeeklyStats {
  const factory WeeklyStats({
    required int sessionsCount,
    required double totalVolume,
    required int streak,
  }) = _WeeklyStats;

  factory WeeklyStats.fromJson(Map<String, dynamic> json) => _$WeeklyStatsFromJson(json);
}
