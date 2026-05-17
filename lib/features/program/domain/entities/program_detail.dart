import 'package:freezed_annotation/freezed_annotation.dart';
import 'program.dart';
import 'program_day.dart';

part 'program_detail.freezed.dart';
part 'program_detail.g.dart';

@freezed
class ProgramDetail with _$ProgramDetail {
  const factory ProgramDetail({
    required Program program,
    required List<ProgramDay> days,
  }) = _ProgramDetail;

  factory ProgramDetail.fromJson(Map<String, dynamic> json) => _$ProgramDetailFromJson(json);
}
