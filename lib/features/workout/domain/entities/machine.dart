import 'package:freezed_annotation/freezed_annotation.dart';

part 'machine.freezed.dart';
part 'machine.g.dart';

@freezed
class Machine with _$Machine {
  const factory Machine({
    int? id,
    required String name,
  }) = _Machine;

  factory Machine.fromJson(Map<String, dynamic> json) => _$MachineFromJson(json);
}
