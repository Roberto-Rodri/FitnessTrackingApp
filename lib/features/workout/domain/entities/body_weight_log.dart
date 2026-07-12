import 'package:freezed_annotation/freezed_annotation.dart';

part 'body_weight_log.freezed.dart';
part 'body_weight_log.g.dart';

@freezed
abstract class BodyWeightLog with _$BodyWeightLog {
  const factory BodyWeightLog({
    required String id,
    required DateTime date,
    required double weight,
    double? bodyFatPercentage,
    double? muscleMass,
    double? waist,
    double? chest,
    double? arms,
    String? notes,
  }) = _BodyWeightLog;

  factory BodyWeightLog.fromJson(Map<String, dynamic> json) => _$BodyWeightLogFromJson(json);
}
