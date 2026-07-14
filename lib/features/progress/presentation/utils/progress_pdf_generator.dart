import 'dart:math';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../profile/domain/entities/user_profile.dart';
import '../../domain/entities/progress_report_data.dart';

// ===========================================================================
// IronLog PDF Style — a clean "paper" light theme that keeps the Ember brand
// accents. Text/cards are grey on white; only phase arrows, PR badges and
// chart lines use the Ember palette (see AGENTS.md §10).
// ===========================================================================

// Ember accents (only used for arrows / badges / chart lines).
const PdfColor _amber = PdfColor.fromInt(0xFFE8A83E);
const PdfColor _coral = PdfColor.fromInt(0xFFC75D3A);
const PdfColor _green = PdfColor.fromInt(0xFF6B9E3A);
const PdfColor _red = PdfColor.fromInt(0xFFD44A3A);

// Paper greys.
const PdfColor _ink = PdfColors.grey900; // primary text
const PdfColor _sub = PdfColors.grey700; // secondary text / labels
const PdfColor _line = PdfColors.grey300; // borders / gridlines
const PdfColor _faint = PdfColors.grey400; // raw data dots

// Layout constants (A4 portrait).
const double _pageMargin = 32;
final double _contentWidth = PdfPageFormat.a4.width - _pageMargin * 2;
const double _cardPadding = 12;
final double _chartWidth = _contentWidth - _cardPadding * 2;

// --- Text styles (strictly built-in fonts) ---
pw.TextStyle _body({double size = 10, PdfColor color = _ink, bool bold = false}) =>
    pw.TextStyle(
      font: bold ? pw.Font.helveticaBold() : pw.Font.helvetica(),
      fontSize: size,
      color: color,
    );

pw.TextStyle _italic({double size = 10, PdfColor color = _sub}) => pw.TextStyle(
      font: pw.Font.helveticaOblique(),
      fontSize: size,
      color: color,
    );

pw.TextStyle _mono({double size = 10, PdfColor color = _ink, bool bold = false}) =>
    pw.TextStyle(
      font: bold ? pw.Font.courierBold() : pw.Font.courier(),
      fontSize: size,
      color: color,
    );

/// Generates the full, multi-page Progress Report PDF.
Future<Uint8List> generateProgressReportPdf(ProgressReportData data) async {
  final doc = pw.Document();
  // Standard PDF fonts for text drawn directly on chart canvases.
  final canvasFont = PdfFont.helvetica(doc.document);
  final dateFmt = DateFormat('MMM d, yyyy');

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(_pageMargin),
      // Safety net: a very large report (many PRs/notes/alerts) can legitimately
      // run long. The default cap is 20, which throws TooManyPagesException.
      maxPages: 100,
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
        italic: pw.Font.helveticaOblique(),
      ),
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 8),
        child: pw.Text(
          'IronLog  ·  Page ${context.pageNumber} of ${context.pagesCount}',
          style: _body(size: 8, color: PdfColors.grey600),
        ),
      ),
      // Build a FRESH, FLAT list every call. Each long list (alerts, PRs, notes)
      // is spread (`...`) as individual top-level widgets so MultiPage can break
      // between them across pages — never wrapped in one master Column, which is
      // atomic and, if taller than a page, loops until TooManyPagesException.
      build: (context) => <pw.Widget>[
        _headerBlock(data, dateFmt),
        pw.SizedBox(height: 18),

        // 01 — Executive Summary (small, stays atomic).
        pw.Column(children: [
          _sectionHeader('01', 'EXECUTIVE SUMMARY'),
          pw.SizedBox(height: 10),
          _kpiGrid(data),
        ]),
        pw.SizedBox(height: 18),

        // 02 — Body Composition.
        ..._bodyCompSection(data, canvasFont),
        pw.SizedBox(height: 18),

        // 03 — Strength & Volume.
        ..._strengthSection(data, canvasFont),
        pw.SizedBox(height: 18),

        // 04 — Details & Alerts.
        ..._detailsSection(data, dateFmt),
      ],
    ),
  );

  return doc.save();
}

// ===========================================================================
// HEADER
// ===========================================================================

pw.Widget _headerBlock(ProgressReportData data, DateFormat dateFmt) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('IronLog Progress Report',
                  style: _body(size: 24, color: _ink, bold: true)),
              pw.SizedBox(height: 4),
              pw.Text(
                '${dateFmt.format(data.startDate)}  -  ${dateFmt.format(data.endDate)}',
                style: _body(size: 11, color: _sub),
              ),
            ],
          ),
          _phaseBadge(data.phase),
        ],
      ),
      pw.SizedBox(height: 14),
      pw.Divider(color: _line, thickness: 1, height: 1),
    ],
  );
}

pw.Widget _phaseBadge(TrainingPhase phase) {
  final PdfColor c;
  switch (phase) {
    case TrainingPhase.cutting:
      c = _coral;
      break;
    case TrainingPhase.maintaining:
      c = _amber;
      break;
    case TrainingPhase.gaining:
      c = _green;
      break;
    case TrainingPhase.none:
      c = _sub;
  }
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: c, width: 1),
      borderRadius: pw.BorderRadius.circular(12),
    ),
    child: pw.Text('PHASE: ${phase.name.toUpperCase()}',
        style: _body(size: 9, color: c, bold: true)),
  );
}

// ===========================================================================
// SECTION HELPERS
// ===========================================================================

pw.Widget _sectionHeader(String number, String title) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      pw.Text(number, style: _mono(size: 11, color: _amber, bold: true)),
      pw.SizedBox(width: 8),
      pw.Text(title,
          style: _body(size: 11, color: _sub, bold: true)
              .copyWith(letterSpacing: 1.0)),
    ],
  );
}

pw.Widget _subHeader(String title) =>
    pw.Text(title, style: _body(size: 11, color: _ink, bold: true));

pw.Widget _card({required pw.Widget child}) {
  return pw.Container(
    width: _contentWidth,
    padding: const pw.EdgeInsets.all(_cardPadding),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _line, width: 0.8),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: child,
  );
}

pw.Widget _hint(String text) {
  return pw.Container(
    width: _contentWidth,
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _line, width: 0.8),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Text(text, style: _italic(size: 10, color: _sub)),
  );
}

// ===========================================================================
// 01 — EXECUTIVE SUMMARY (KPI grid, phase-aware arrows)
// ===========================================================================

/// Returns (color, direction) where direction is 1=up, -1=down, 0=flat.
(PdfColor, int) _deltaStyle(double delta, TrainingPhase phase) {
  if (delta == 0) return (_sub, 0);
  final negative = delta < 0;
  final dir = negative ? -1 : 1;
  switch (phase) {
    case TrainingPhase.cutting:
      return (negative ? _green : _red, dir);
    case TrainingPhase.gaining:
      return (negative ? _red : _green, dir);
    case TrainingPhase.maintaining:
      return (delta.abs() <= 0.5 ? _green : _red, dir);
    case TrainingPhase.none:
      return (_sub, dir);
  }
}

pw.Widget _kpiGrid(ProgressReportData data) {
  final (rocColor, rocDir) = _deltaStyle(data.weeklyRateOfChange.pctPerWeek, data.phase);

  double startWt = 0;
  double endWt = 0;
  if (data.weightTrend.rawPoints.isNotEmpty) {
    startWt = data.weightTrend.rawPoints.first.value;
    endWt = data.weightTrend.rawPoints.last.value;
  }
  final wtDelta = endWt - startWt;
  final (wtColor, wtDir) = _deltaStyle(wtDelta, data.phase);
  final wtSign = wtDelta > 0 ? '+' : (wtDelta < 0 ? '-' : '');

  final consistency = data.consistency.planned != null
      ? '${data.consistency.completed}/${data.consistency.planned}'
      : '${data.consistency.completed}';

  return pw.Container(
    width: _contentWidth,
    child: pw.Column(
      children: [
        pw.Row(
          children: [
            _kpiCell(
              'Rate of Change',
              '${data.weeklyRateOfChange.pctPerWeek.abs().toStringAsFixed(2)}%/wk',
              arrowColor: rocColor,
              arrowDir: rocDir,
              showArrow: true,
            ),
            pw.SizedBox(width: 12),
            _kpiCell(
              data.weightTrend.isSparse ? 'Raw Wt Change' : 'Weight Trend',
              '$wtSign${wtDelta.abs().toStringAsFixed(1)} kg',
              arrowColor: wtColor,
              arrowDir: wtDir,
              showArrow: true,
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          children: [
            _kpiCell('Consistency', consistency),
            pw.SizedBox(width: 12),
            _kpiCell('Adherence', '${data.adherence.pct.toStringAsFixed(0)}%'),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _kpiCell(
  String label,
  String value, {
  PdfColor arrowColor = _sub,
  int arrowDir = 0,
  bool showArrow = false,
}) {
  return pw.Expanded(
    child: pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _line, width: 0.8),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: _body(size: 10, color: _sub)),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Expanded(
                child: pw.Text(value, style: _mono(size: 16, color: _ink, bold: true)),
              ),
              if (showArrow) ...[
                pw.SizedBox(width: 6),
                _arrowGlyph(arrowDir, arrowColor),
              ],
            ],
          ),
        ],
      ),
    ),
  );
}

/// A filled triangle arrow (dir: 1=up, -1=down, 0=flat bar). Drawn instead of
/// a Unicode glyph because the built-in PDF fonts don't encode ↑ ↓ ↔.
pw.Widget _arrowGlyph(int dir, PdfColor color) {
  return pw.SizedBox(
    width: 9,
    height: 9,
    child: pw.CustomPaint(
      size: const PdfPoint(9, 9),
      painter: (canvas, size) {
        final w = size.x;
        final h = size.y;
        canvas.setFillColor(color);
        if (dir > 0) {
          canvas
            ..moveTo(w / 2, h)
            ..lineTo(0, h * 0.3)
            ..lineTo(w, h * 0.3)
            ..closePath()
            ..fillPath();
        } else if (dir < 0) {
          canvas
            ..moveTo(w / 2, 0)
            ..lineTo(0, h * 0.7)
            ..lineTo(w, h * 0.7)
            ..closePath()
            ..fillPath();
        } else {
          canvas
            ..drawRect(0, h * 0.4, w, h * 0.2)
            ..fillPath();
        }
      },
    ),
  );
}

// ===========================================================================
// 02 — BODY COMPOSITION
// ===========================================================================

List<pw.Widget> _bodyCompSection(ProgressReportData data, PdfFont font) {
  final header = _sectionHeader('02', 'BODY COMPOSITION');

  if (data.weightTrend.rawPoints.isEmpty) {
    return [
      pw.Column(children: [
        header,
        pw.SizedBox(height: 10),
        _hint('Log your weight to unlock body composition analysis.'),
      ]),
    ];
  }

  final widgets = <pw.Widget>[
    pw.Column(children: [
      header,
      pw.SizedBox(height: 10),
      _weightCard(data.weightTrend, font),
    ]),
  ];

  final hasRecomp = data.bodyComposition.any((c) => c.points.isNotEmpty);
  if (hasRecomp) {
    widgets.add(pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10),
      child: _recompCard(data.bodyComposition),
    ));
  }
  return widgets;
}

pw.Widget _weightCard(WeightTrendData trend, PdfFont font) {
  final values = trend.rawPoints.map((e) => e.value).toList();
  final minWt = values.reduce(min);
  final maxWt = values.reduce(max);

  return _card(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Weight Trend', style: _body(size: 12, color: _ink, bold: true)),
            if (trend.isSparse)
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _line, width: 0.8),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text('SPARSE DATA', style: _mono(size: 7, color: _sub)),
              ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.CustomPaint(
          size: PdfPoint(_chartWidth, 120),
          painter: (canvas, size) => _paintWeightChart(canvas, size, trend),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _legendDot(_faint, 'Logged', mono: false),
            _legendDot(trend.isSparse ? _sub : _amber,
                trend.isSparse ? 'Slope (sparse)' : 'EMA trend',
                mono: false),
            pw.Text('${minWt.toStringAsFixed(1)}-${maxWt.toStringAsFixed(1)} kg',
                style: _mono(size: 8, color: _sub)),
          ],
        ),
      ],
    ),
  );
}

void _paintWeightChart(PdfGraphics canvas, PdfPoint size, WeightTrendData d) {
  if (d.rawPoints.isEmpty) return;
  const pad = 6.0;
  final chartW = size.x - pad * 2;
  final chartH = size.y - pad * 2;

  double minWt = d.rawPoints.map((e) => e.value).reduce(min);
  double maxWt = d.rawPoints.map((e) => e.value).reduce(max);
  if (d.trendPoints.isNotEmpty) {
    minWt = min(minWt, d.trendPoints.map((e) => e.value).reduce(min));
    maxWt = max(maxWt, d.trendPoints.map((e) => e.value).reduce(max));
  }
  if (maxWt - minWt < 2) {
    minWt -= 1;
    maxWt += 1;
  }

  int minT = d.rawPoints.first.date.millisecondsSinceEpoch;
  int maxT = d.rawPoints.last.date.millisecondsSinceEpoch;
  if (maxT == minT) maxT += 86400000;

  double x(int t) => pad + (t - minT) / (maxT - minT) * chartW;
  double y(double v) => pad + (v - minWt) / (maxWt - minWt) * chartH;

  // Frame.
  canvas
    ..setStrokeColor(_line)
    ..setLineWidth(0.5)
    ..drawRect(pad, pad, chartW, chartH)
    ..strokePath();

  // Raw points.
  canvas.setFillColor(_faint);
  for (final p in d.rawPoints) {
    canvas
      ..drawEllipse(x(p.date.millisecondsSinceEpoch), y(p.value), 1.7, 1.7)
      ..fillPath();
  }

  // Trend line.
  if (d.isSparse || d.trendPoints.isEmpty) {
    final p1 = d.rawPoints.first;
    final p2 = d.rawPoints.last;
    canvas
      ..setStrokeColor(_sub)
      ..setLineWidth(1.5)
      ..drawLine(x(p1.date.millisecondsSinceEpoch), y(p1.value),
          x(p2.date.millisecondsSinceEpoch), y(p2.value))
      ..strokePath();
  } else {
    canvas
      ..setStrokeColor(_amber)
      ..setLineWidth(1.8);
    var first = true;
    for (final p in d.trendPoints) {
      final px = x(p.date.millisecondsSinceEpoch);
      final py = y(p.value);
      if (first) {
        canvas.moveTo(px, py);
        first = false;
      } else {
        canvas.lineTo(px, py);
      }
    }
    canvas.strokePath();
  }
}

pw.Widget _recompCard(List<BodyCompositionSeries> series) {
  final drawable = series.where((s) => s.points.isNotEmpty).toList();
  final colors = [_coral, _green, _amber];

  return _card(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Body Metrics', style: _body(size: 12, color: _ink, bold: true)),
        pw.SizedBox(height: 10),
        pw.CustomPaint(
          size: PdfPoint(_chartWidth, 120),
          painter: (canvas, size) => _paintMultiSeries(canvas, size, drawable),
        ),
        pw.SizedBox(height: 8),
        pw.Wrap(
          spacing: 14,
          runSpacing: 4,
          children: List.generate(drawable.length, (i) {
            return _legendDot(colors[i % colors.length],
                _prettyMetric(drawable[i].metricName),
                mono: false);
          }),
        ),
      ],
    ),
  );
}

// ===========================================================================
// 03 — STRENGTH & VOLUME
// ===========================================================================

List<pw.Widget> _strengthSection(ProgressReportData data, PdfFont font) {
  final header = _sectionHeader('03', 'STRENGTH & VOLUME');

  if (data.effectiveSets.isEmpty && data.e1rmData.isEmpty) {
    return [
      pw.Column(children: [
        header,
        pw.SizedBox(height: 10),
        _hint('Complete workouts to track sets and strength trends.'),
      ]),
    ];
  }

  final cards = <pw.Widget>[];
  if (data.effectiveSets.isNotEmpty) {
    cards.add(_effectiveSetsCard(data.effectiveSets, font));
  }
  if (data.e1rmData.isNotEmpty) {
    cards.add(_e1rmCard(data.e1rmData));
  }

  final widgets = <pw.Widget>[
    pw.Column(children: [header, pw.SizedBox(height: 10), cards.first]),
  ];
  for (final c in cards.skip(1)) {
    widgets.add(pw.Padding(padding: const pw.EdgeInsets.only(top: 10), child: c));
  }
  return widgets;
}

pw.Widget _effectiveSetsCard(List<EffectiveSetCount> sets, PdfFont font) {
  final height = max(70.0, sets.length * 22.0);
  return _card(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Effective Sets per Muscle',
            style: _body(size: 12, color: _ink, bold: true)),
        pw.SizedBox(height: 12),
        pw.CustomPaint(
          size: PdfPoint(_chartWidth, height),
          painter: (canvas, size) => _paintEffectiveSets(canvas, size, sets, font),
        ),
      ],
    ),
  );
}

void _paintEffectiveSets(
    PdfGraphics canvas, PdfPoint size, List<EffectiveSetCount> data, PdfFont font) {
  if (data.isEmpty) return;
  final w = size.x;
  final h = size.y;

  var maxCount = data.map((e) => e.count).reduce(max);
  maxCount = max(25, maxCount); // keep MEV(10)/MRV(20) on-scale

  const leftLabel = 88.0;
  const rightPad = 26.0;
  final trackW = w - leftLabel - rightPad;
  final rowH = h / data.length;
  final barH = min(11.0, rowH * 0.55);

  double xForCount(int c) => leftLabel + (c / maxCount) * trackW;

  // MEV / MRV reference lines.
  canvas
    ..setStrokeColor(_line)
    ..setLineWidth(0.5);
  for (final ref in const [10, 20]) {
    if (ref > maxCount) continue;
    final rx = xForCount(ref);
    canvas
      ..drawLine(rx, 0, rx, h)
      ..strokePath();
  }
  canvas.setFillColor(_sub);
  if (10 <= maxCount) canvas.drawString(font, 6, 'MEV', xForCount(10) + 1.5, h - 7);
  if (20 <= maxCount) canvas.drawString(font, 6, 'MRV', xForCount(20) + 1.5, h - 7);

  for (var i = 0; i < data.length; i++) {
    final item = data[i];
    // Rows top-to-bottom.
    final yTop = h - (i + 1) * rowH + (rowH - barH) / 2;

    canvas
      ..setFillColor(_amber)
      ..drawRect(leftLabel, yTop, xForCount(item.count) - leftLabel, barH)
      ..fillPath();

    canvas
      ..setFillColor(_ink)
      ..drawString(font, 8, item.bodyPart, 0, yTop + barH / 2 - 3);

    canvas
      ..setFillColor(_sub)
      ..drawString(font, 7, '${item.count}', xForCount(item.count) + 3, yTop + barH / 2 - 2.5);
  }
}

pw.Widget _e1rmCard(List<E1rmSeries> e1rm) {
  final drawable = e1rm.where((s) => s.points.isNotEmpty).toList();
  final colors = [_amber, _coral, _green];
  return _card(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Estimated 1RM Trend', style: _body(size: 12, color: _ink, bold: true)),
        pw.SizedBox(height: 10),
        pw.CustomPaint(
          size: PdfPoint(_chartWidth, 130),
          painter: (canvas, size) => _paintMultiSeries(
            canvas,
            size,
            drawable.map((s) => BodyCompositionSeries(
                  metricName: s.exerciseName,
                  points: s.points,
                )).toList(),
            endDots: true,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Wrap(
          spacing: 14,
          runSpacing: 4,
          children: List.generate(drawable.length, (i) {
            return _legendDot(colors[i % colors.length], drawable[i].exerciseName,
                mono: false);
          }),
        ),
      ],
    ),
  );
}

/// Draws multiple line series, each normalised to its own min/max so every
/// line uses the full vertical space (matches the on-screen recomp chart).
void _paintMultiSeries(
  PdfGraphics canvas,
  PdfPoint size,
  List<BodyCompositionSeries> seriesList, {
  bool endDots = false,
}) {
  if (seriesList.isEmpty) return;
  const pad = 6.0;
  final chartW = size.x - pad * 2;
  final chartH = size.y - pad * 2;
  final colors = [_coral, _green, _amber, _red];

  // Shared time axis across all series.
  final allTimes = seriesList
      .expand((s) => s.points)
      .map((p) => p.date.millisecondsSinceEpoch)
      .toList();
  if (allTimes.isEmpty) return;
  int minT = allTimes.reduce(min);
  int maxT = allTimes.reduce(max);
  if (maxT == minT) maxT += 86400000;
  double x(int t) => pad + (t - minT) / (maxT - minT) * chartW;

  // Frame.
  canvas
    ..setStrokeColor(_line)
    ..setLineWidth(0.5)
    ..drawRect(pad, pad, chartW, chartH)
    ..strokePath();

  for (var i = 0; i < seriesList.length; i++) {
    final series = seriesList[i];
    if (series.points.isEmpty) continue;
    final color = colors[i % colors.length];

    double minV = series.points.map((e) => e.value).reduce(min);
    double maxV = series.points.map((e) => e.value).reduce(max);
    if (maxV == minV) {
      minV -= 1;
      maxV += 1;
    }
    double y(double v) => pad + (v - minV) / (maxV - minV) * chartH;

    canvas
      ..setStrokeColor(color)
      ..setLineWidth(1.6);
    var first = true;
    for (final p in series.points) {
      final px = x(p.date.millisecondsSinceEpoch);
      final py = y(p.value);
      if (first) {
        canvas.moveTo(px, py);
        first = false;
      } else {
        canvas.lineTo(px, py);
      }
    }
    canvas.strokePath();

    if (endDots) {
      final last = series.points.last;
      canvas
        ..setFillColor(color)
        ..drawEllipse(x(last.date.millisecondsSinceEpoch), y(last.value), 2.2, 2.2)
        ..fillPath();
    }
  }
}

// ===========================================================================
// 04 — DETAILS & ALERTS
// ===========================================================================

List<pw.Widget> _detailsSection(ProgressReportData data, DateFormat dateFmt) {
  final header = _sectionHeader('04', 'DETAILS & ALERTS');
  final out = <pw.Widget>[];

  // Alerts — short, app-generated strings, safe inside their accent-bar boxes.
  final alertRows = <pw.Widget>[];
  if (data.alerts.isEmpty) {
    alertRows.add(_hint('No active alerts.'));
  } else {
    alertRows.addAll(data.alerts.map(_alertRow));
  }

  // Glue the section header to the first (short) alert row so it can't orphan.
  out.add(pw.Column(children: [header, pw.SizedBox(height: 10), alertRows.first]));
  for (final r in alertRows.skip(1)) {
    out
      ..add(pw.SizedBox(height: 8))
      ..add(r);
  }

  // Personal Records — single-line rows, always shorter than a page.
  if (data.prs.isNotEmpty) {
    out
      ..add(pw.SizedBox(height: 14))
      ..add(_subHeader('Personal Records'));
    for (final pr in data.prs) {
      out
        ..add(pw.SizedBox(height: 8))
        ..add(_prRow(pr, dateFmt));
    }
  }

  // Athlete Notes — free-form text of unbounded length. Rendered as raw pw.Text
  // spread directly into the array (NO Container/Padding wrapper, which would be
  // an un-splittable block). A single pw.Text still can't span pages in this pdf
  // version, so notes longer than a page are split into page-safe chunks.
  if (data.sessionNotes.isNotEmpty) {
    out
      ..add(pw.SizedBox(height: 14))
      ..add(_subHeader('Athlete Notes'));
    for (final note in data.sessionNotes) {
      out
        ..add(pw.SizedBox(height: 8))
        ..addAll(_noteWidgets(note));
    }
  }

  return out;
}

/// Renders one athlete note as one or more raw pw.Text widgets. A pw.Text taller
/// than a page throws ("won't fit") because pw.Text doesn't span pages here, so
/// very long notes are broken into ~page-safe word chunks. Normal short notes
/// stay a single clean paragraph.
List<pw.Widget> _noteWidgets(String note) {
  const maxWordsPerChunk = 300; // comfortably under one A4 page at 10pt
  final quoted = '"$note"';
  final words = quoted.split(RegExp(r'\s+'));
  if (words.length <= maxWordsPerChunk) {
    return [pw.Text(quoted, style: _italic(size: 10, color: _sub))];
  }
  final chunks = <pw.Widget>[];
  for (var i = 0; i < words.length; i += maxWordsPerChunk) {
    final end =
        (i + maxWordsPerChunk) < words.length ? i + maxWordsPerChunk : words.length;
    chunks.add(pw.Text(words.sublist(i, end).join(' '),
        style: _italic(size: 10, color: _sub)));
  }
  return chunks;
}

pw.Widget _alertRow(AlertData alert) {
  final isWarning = alert.severity == AlertSeverity.warning;
  final color = isWarning ? _coral : _green;
  return pw.Container(
    width: _contentWidth,
    padding: const pw.EdgeInsets.fromLTRB(10, 8, 10, 8),
    decoration: pw.BoxDecoration(
      border: pw.Border(
        left: pw.BorderSide(color: color, width: 3),
        top: pw.BorderSide(color: _line, width: 0.8),
        right: pw.BorderSide(color: _line, width: 0.8),
        bottom: pw.BorderSide(color: _line, width: 0.8),
      ),
    ),
    child: pw.Text(alert.text, style: _body(size: 10, color: _ink)),
  );
}

pw.Widget _prRow(PR pr, DateFormat dateFmt) {
  return pw.Container(
    width: _contentWidth,
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _amber, width: 0.8),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text('PR', style: _mono(size: 8, color: _amber, bold: true)),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(child: pw.Text(pr.exerciseName, style: _body(size: 10, color: _ink))),
        pw.Text('${pr.weight}kg × ${pr.reps}', style: _mono(size: 10, color: _ink)),
        pw.SizedBox(width: 10),
        pw.Text(DateFormat('MMM d').format(pr.date), style: _body(size: 9, color: _sub)),
      ],
    ),
  );
}

// ===========================================================================
// SHARED
// ===========================================================================

pw.Widget _legendDot(PdfColor color, String label, {bool mono = false}) {
  return pw.Row(
    mainAxisSize: pw.MainAxisSize.min,
    children: [
      pw.Container(
        width: 8,
        height: 8,
        decoration: pw.BoxDecoration(color: color, shape: pw.BoxShape.circle),
      ),
      pw.SizedBox(width: 4),
      pw.Text(label,
          style: mono ? _mono(size: 8, color: _sub) : _body(size: 8, color: _sub)),
    ],
  );
}

String _prettyMetric(String metric) {
  switch (metric) {
    case 'bodyFatPercentage':
      return 'Body Fat %';
    case 'muscleMass':
      return 'Muscle Mass';
    case 'waist':
      return 'Waist';
    case 'chest':
      return 'Chest';
    case 'arms':
      return 'Arms';
    default:
      return metric;
  }
}
