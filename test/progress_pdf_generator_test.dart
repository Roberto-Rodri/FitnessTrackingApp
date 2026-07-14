import 'package:flutter_test/flutter_test.dart';
import 'package:iron_log/features/profile/domain/entities/user_profile.dart';
import 'package:iron_log/features/progress/domain/entities/progress_report_data.dart';
import 'package:iron_log/features/progress/presentation/utils/progress_pdf_generator.dart';

ProgressReportData _makeData({
  int prCount = 0,
  int alertCount = 0,
  List<String> notes = const [],
  bool withWeight = false,
  bool withEffectiveSets = false,
  bool withE1rm = false,
  bool withBodyComp = false,
}) {
  final start = DateTime(2026, 7, 1);
  final end = DateTime(2026, 7, 14);

  return ProgressReportData(
    startDate: start,
    endDate: end,
    phase: TrainingPhase.cutting,
    e1rmData: withE1rm
        ? [
            E1rmSeries(exerciseName: 'Bench Press', points: [
              DataPoint(date: start, value: 100),
              DataPoint(date: end, value: 110),
            ]),
          ]
        : const [],
    weightTrend: WeightTrendData(
      isSparse: false,
      rawPoints: withWeight
          ? [
              DataPoint(date: start, value: 80),
              DataPoint(date: end, value: 78),
            ]
          : const [],
      trendPoints: withWeight
          ? [
              DataPoint(date: start, value: 80),
              DataPoint(date: end, value: 78.5),
            ]
          : const [],
      emaAlpha: 0.15,
    ),
    weeklyRateOfChange: const RateOfChange(absPerWeek: -1.0, pctPerWeek: -1.2),
    effectiveSets: withEffectiveSets
        ? const [
            EffectiveSetCount(bodyPart: 'Chest', count: 12),
            EffectiveSetCount(bodyPart: 'Back', count: 18),
          ]
        : const [],
    adherence: const AdherenceData(pct: 85, setsHit: 40, setsTotal: 47),
    consistency: const ConsistencyData(completed: 4, planned: 5),
    prs: List.generate(
      prCount,
      (i) => PR(
        exerciseName: 'Exercise $i Barbell long label',
        weight: 100.0 + i,
        reps: 5,
        date: start.add(Duration(days: i % 14)),
      ),
    ),
    bodyComposition: withBodyComp
        ? [
            BodyCompositionSeries(metricName: 'muscleMass', points: [
              DataPoint(date: start, value: 40),
              DataPoint(date: end, value: 41),
            ]),
          ]
        : const [],
    alerts: List.generate(
      alertCount,
      (i) => AlertData(severity: AlertSeverity.warning, text: 'Alert number $i text.'),
    ),
    sessionNotes: notes,
  );
}

Future<void> _expectOk(ProgressReportData data) async {
  final bytes = await generateProgressReportPdf(data);
  expect(bytes.lengthInBytes, greaterThan(0));
}

void main() {
  test('empty report generates without crashing', () async {
    await _expectOk(_makeData());
  });

  test('full report: 20 PRs, alerts, notes, all charts', () async {
    await _expectOk(_makeData(
      prCount: 20,
      alertCount: 3,
      notes: const ['Felt strong today.', 'Deload next week.'],
      withWeight: true,
      withEffectiveSets: true,
      withE1rm: true,
      withBodyComp: true,
    ));
  });

  test('very large report: 40 PRs + one page-length note', () async {
    final longNote =
        List.filled(400, 'This is a very long athlete note sentence.').join(' ');
    await _expectOk(_makeData(
      prCount: 40,
      alertCount: 5,
      notes: [longNote, 'Short note.'],
      withWeight: true,
      withEffectiveSets: true,
      withE1rm: true,
      withBodyComp: true,
    ));
  });

  test('extreme stress: 100 PRs + several multi-page notes', () async {
    final hugeNote =
        List.filled(1200, 'Extremely long run-on athlete note sentence.').join(' ');
    await _expectOk(_makeData(
      prCount: 100,
      alertCount: 8,
      notes: [hugeNote, hugeNote, 'Short one.'],
      withWeight: true,
      withEffectiveSets: true,
      withE1rm: true,
      withBodyComp: true,
    ));
  });
}
