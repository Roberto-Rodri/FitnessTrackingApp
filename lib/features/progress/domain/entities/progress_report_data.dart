import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:iron_log/features/profile/domain/entities/user_profile.dart';
part 'progress_report_data.freezed.dart';

@freezed
abstract class ProgressReportData with _$ProgressReportData {
  const factory ProgressReportData({
    required DateTime startDate,
    required DateTime endDate,
    required TrainingPhase phase,
    required List<E1rmSeries> e1rmData,
    required WeightTrendData weightTrend,
    required RateOfChange weeklyRateOfChange,
    required List<EffectiveSetCount> effectiveSets,
    required AdherenceData adherence,
    required ConsistencyData consistency,
    required List<PR> prs,
    required List<BodyCompositionSeries> bodyComposition,
    required List<AlertData> alerts,
    required List<String> sessionNotes,
  }) = _ProgressReportData;
}

@freezed
abstract class E1rmSeries with _$E1rmSeries {
  const factory E1rmSeries({
    required String exerciseName,
    required List<DataPoint> points,
  }) = _E1rmSeries;
}

@freezed
abstract class DataPoint with _$DataPoint {
  const factory DataPoint({
    required DateTime date,
    required double value,
  }) = _DataPoint;
}

@freezed
abstract class WeightTrendData with _$WeightTrendData {
  const factory WeightTrendData({
    required bool isSparse,
    required List<DataPoint> rawPoints,
    required List<DataPoint> trendPoints, // Empty if sparse
    required double? emaAlpha,
  }) = _WeightTrendData;
}

@freezed
abstract class RateOfChange with _$RateOfChange {
  const factory RateOfChange({
    required double absPerWeek,
    required double pctPerWeek,
  }) = _RateOfChange;
}

@freezed
abstract class EffectiveSetCount with _$EffectiveSetCount {
  const factory EffectiveSetCount({
    required String bodyPart,
    required int count,
  }) = _EffectiveSetCount;
}

@freezed
abstract class AdherenceData with _$AdherenceData {
  const factory AdherenceData({
    required double pct,
    required int setsHit,
    required int setsTotal,
  }) = _AdherenceData;
}

@freezed
abstract class ConsistencyData with _$ConsistencyData {
  const factory ConsistencyData({
    required int completed,
    int? planned,
    double? pct,
  }) = _ConsistencyData;
}

@freezed
abstract class PR with _$PR {
  const factory PR({
    required String exerciseName,
    required double weight,
    required int reps,
    required DateTime date,
  }) = _PR;
}

@freezed
abstract class BodyCompositionSeries with _$BodyCompositionSeries {
  const factory BodyCompositionSeries({
    required String metricName, // bodyFatPercentage, muscleMass, etc.
    required List<DataPoint> points,
  }) = _BodyCompositionSeries;
}

enum AlertSeverity { warning, good }

@freezed
abstract class AlertData with _$AlertData {
  const factory AlertData({
    required AlertSeverity severity,
    required String text,
  }) = _AlertData;
}
