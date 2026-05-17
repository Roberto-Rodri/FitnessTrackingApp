import 'package:freezed_annotation/freezed_annotation.dart';

part 'routine_summary.freezed.dart';
part 'routine_summary.g.dart';

@freezed
class RoutineSummary with _$RoutineSummary {
  const factory RoutineSummary({
    required int id,
    required String name,
    required int exerciseCount,
    String? exerciseNames, // nullable as GROUP_CONCAT returns null when 0 exercises
  }) = _RoutineSummary;

  factory RoutineSummary.fromJson(Map<String, dynamic> json) => _$RoutineSummaryFromJson(json);
}
