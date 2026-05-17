import 'package:freezed_annotation/freezed_annotation.dart';

part 'program_day.freezed.dart';
part 'program_day.g.dart';

@freezed
class ProgramDay with _$ProgramDay {
  const factory ProgramDay({
    int? id,
    required int programId,
    required int dayIndex,
    int? routineId, // nullable — null = rest day
    required String label,
  }) = _ProgramDay;

  factory ProgramDay.fromJson(Map<String, dynamic> json) => _$ProgramDayFromJson(json);
}
