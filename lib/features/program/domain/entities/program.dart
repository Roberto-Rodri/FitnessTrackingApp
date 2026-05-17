import 'package:freezed_annotation/freezed_annotation.dart';

part 'program.freezed.dart';
part 'program.g.dart';

bool _intToBool(int value) => value == 1;
int _boolToInt(bool value) => value ? 1 : 0;

@freezed
class Program with _$Program {
  const factory Program({
    int? id,
    required String name,
    required int cycleLengthDays,
    @JsonKey(fromJson: _intToBool, toJson: _boolToInt) @Default(false) bool isActive,
    @Default(0) int currentDayIndex,
  }) = _Program;

  factory Program.fromJson(Map<String, dynamic> json) => _$ProgramFromJson(json);
}
