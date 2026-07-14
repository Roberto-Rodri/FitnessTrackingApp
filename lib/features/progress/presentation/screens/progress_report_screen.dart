import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/theme.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../domain/entities/progress_report_data.dart';
import '../controllers/progress_providers.dart';
import '../utils/progress_pdf_generator.dart';

class ProgressReportScreen extends ConsumerStatefulWidget {
  const ProgressReportScreen({super.key});

  @override
  ConsumerState<ProgressReportScreen> createState() => _ProgressReportScreenState();
}

class _ProgressReportScreenState extends ConsumerState<ProgressReportScreen> {
  late DateTime _startDate;
  late DateTime _endDate;

  // Captures the full report surface for image export. Attached in the widget
  // tree unconditionally (see `_buildReportContent`), so it is valid even if
  // the user has not scrolled the report.
  final GlobalKey _reportKey = GlobalKey();
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    _startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.amber,
                  onPrimary: AppTheme.bg0,
                  surface: AppTheme.bg1,
                  onSurface: AppTheme.txt0,
                ),
          ),
          child: child!,
        );
      },
    );

    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
      });
    }
  }

  // --- Export ---

  void _showExportSheet() {
    // Only offer export when a report has actually been generated.
    final data = ref.read(progressReportProvider(_startDate, _endDate)).value;
    if (data == null) {
      _showError('Report is still loading. Please try again in a moment.');
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.bg2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.bg3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'EXPORT REPORT',
                    style: Theme.of(sheetContext).textTheme.labelSmall?.copyWith(
                          color: AppTheme.txt2,
                          letterSpacing: 1.0,
                        ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.image_outlined, color: AppTheme.amber),
                title: const Text('Share as Image', style: TextStyle(color: AppTheme.txt0)),
                subtitle: const Text('A single PNG snapshot', style: TextStyle(color: AppTheme.txt2)),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _shareAsImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.amber),
                title: const Text('Share as PDF', style: TextStyle(color: AppTheme.txt0)),
                subtitle: const Text('A paginated document', style: TextStyle(color: AppTheme.txt2)),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _shareAsPdf();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareAsImage() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      // Let the loading overlay paint before we do the synchronous capture.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final boundary =
          _reportKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Report is not ready to capture.');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Failed to render image.');

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/ironlog_progress_report.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My IronLog progress report',
        sharePositionOrigin:
            box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      );
    } catch (e) {
      _showError('Could not export image: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _shareAsPdf() async {
    if (_isExporting) return;

    final data = ref.read(progressReportProvider(_startDate, _endDate)).value;
    if (data == null) {
      _showError('Report is not ready yet. Please wait for it to load.');
      return;
    }

    setState(() => _isExporting = true);
    try {
      final bytes = await generateProgressReportPdf(data);

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/ironlog_progress_report.pdf');
      await file.writeAsBytes(bytes);

      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My IronLog progress report',
        sharePositionOrigin:
            box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      );
    } catch (e) {
      _showError('Could not export PDF: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: AppTheme.txt0)),
        backgroundColor: AppTheme.coral,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reportAsync = ref.watch(progressReportProvider(_startDate, _endDate));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Progress Report'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Export report',
            onPressed: _isExporting ? null : _showExportSheet,
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildDateRangeHeader(theme),
                Expanded(
                  child: reportAsync.when(
                    data: (data) => _buildReportContent(context, theme, data),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
                          const SizedBox(height: 16),
                          Text('Failed to generate report:\n$e', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.invalidate(progressReportProvider(_startDate, _endDate)),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isExporting) _buildExportingOverlay(theme),
        ],
      ),
    );
  }

  Widget _buildExportingOverlay(ThemeData theme) {
    return Positioned.fill(
      child: ColoredBox(
        color: AppTheme.bg0.withValues(alpha: 0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppTheme.amber),
              const SizedBox(height: 16),
              Text(
                'Preparing export…',
                style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeHeader(ThemeData theme) {
    final format = DateFormat('MMM d, yyyy');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.bg1,
        border: Border(bottom: BorderSide(color: AppTheme.bg3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: AppTheme.txt2),
              const SizedBox(width: 8),
              Text(
                '${format.format(_startDate)} - ${format.format(_endDate)}',
                style: theme.textTheme.titleSmall?.copyWith(color: AppTheme.txt0),
              ),
            ],
          ),
          TextButton(
            onPressed: _pickDateRange,
            child: const Text('Change', style: TextStyle(color: AppTheme.amber)),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(BuildContext context, ThemeData theme, ProgressReportData data) {
    // A non-lazy SingleChildScrollView lays out the entire report, so the
    // RepaintBoundary below has valid geometry for the full surface even when
    // the user has not scrolled to the bottom. The solid bg0 Container keeps
    // the captured PNG opaque rather than transparent.
    return SingleChildScrollView(
      child: RepaintBoundary(
        key: _reportKey,
        child: Container(
          color: AppTheme.bg0,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPhaseBadge(theme, data.phase),
              const SizedBox(height: 24),
              _buildStratum1(theme, data),
              const SizedBox(height: 32),
              _buildStratum2(theme, data),
              const SizedBox(height: 32),
              _buildStratum3(theme, data),
              const SizedBox(height: 32),
              _buildStratum4(theme, data),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseBadge(ThemeData theme, TrainingPhase phase) {
    Color color;
    switch (phase) {
      case TrainingPhase.cutting:
        color = AppTheme.coral;
        break;
      case TrainingPhase.maintaining:
        color = AppTheme.amber;
        break;
      case TrainingPhase.gaining:
        color = AppTheme.green;
        break;
      case TrainingPhase.none:
        color = AppTheme.txt2;
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(
          'PHASE: ${phase.name.toUpperCase()}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  // --- Phase-Aware Logic ---
  (Color, String) _getWeightDeltaStyle(double delta, TrainingPhase phase) {
    if (delta == 0) return (AppTheme.txt1, '↔');
    final isNegative = delta < 0;
    final arrow = isNegative ? '↓' : '↑';
    
    if (phase == TrainingPhase.cutting) {
      return (isNegative ? AppTheme.green : AppTheme.error, arrow);
    } else if (phase == TrainingPhase.gaining) {
      return (!isNegative ? AppTheme.green : AppTheme.error, arrow);
    } else if (phase == TrainingPhase.maintaining) {
      return (delta.abs() <= 0.5 ? AppTheme.green : AppTheme.error, arrow);
    }
    return (AppTheme.txt1, arrow); // Neutral
  }

  // --- Stratum 1: Executive Summary ---
  Widget _buildStratum1(ThemeData theme, ProgressReportData data) {
    final (rocColor, rocArrow) = _getWeightDeltaStyle(data.weeklyRateOfChange.pctPerWeek, data.phase);
    
    double startWt = 0;
    double endWt = 0;
    if (data.weightTrend.rawPoints.isNotEmpty) {
      startWt = data.weightTrend.rawPoints.first.value;
      endWt = data.weightTrend.rawPoints.last.value;
    }
    final wtDelta = endWt - startWt;
    final (wtColor, wtArrow) = _getWeightDeltaStyle(wtDelta, data.phase);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('EXECUTIVE SUMMARY', style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.txt2, letterSpacing: 1.0)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildKPICard(theme, 'Rate of Change', '${data.weeklyRateOfChange.pctPerWeek.abs().toStringAsFixed(2)}%/wk', rocColor, rocArrow)),
            const SizedBox(width: 12),
            Expanded(child: _buildKPICard(theme, data.weightTrend.isSparse ? 'Raw Wt Change' : 'Weight Trend', '${wtDelta.abs().toStringAsFixed(1)} kg', wtColor, wtArrow)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildKPICard(theme, 'Consistency', '${data.consistency.completed}${data.consistency.planned != null ? '/${data.consistency.planned}' : ''}', AppTheme.txt1, null)),
            const SizedBox(width: 12),
            Expanded(child: _buildKPICard(theme, 'Adherence', '${data.adherence.pct.toStringAsFixed(0)}%', AppTheme.txt1, null)),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard(ThemeData theme, String label, String value, Color chipColor, String? arrow) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bg1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bg3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.txt1), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(value, style: AppTheme.monoLarge(), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              if (arrow != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: chipColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(arrow, style: AppTheme.monoSmall(color: chipColor).copyWith(fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Stratum 2: Body Composition ---
  Widget _buildStratum2(ThemeData theme, ProgressReportData data) {
    if (data.weightTrend.rawPoints.isEmpty) {
      return _buildCollapsedSection(theme, 'BODY COMPOSITION', 'Log your weight to unlock body composition analysis.');
    }

    final hasRecomp = data.bodyComposition.isNotEmpty && data.bodyComposition.any((c) => c.points.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BODY COMPOSITION', style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.txt2, letterSpacing: 1.0)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bg1,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.bg3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Weight Trend', style: theme.textTheme.titleSmall?.copyWith(color: AppTheme.txt0)),
                  if (data.weightTrend.isSparse)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.bg2,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('SPARSE DATA', style: AppTheme.monoSmall(color: AppTheme.txt2).copyWith(fontSize: 10)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                width: double.infinity,
                child: CustomPaint(
                  painter: _WeightChartPainter(data.weightTrend),
                ),
              ),
              if (hasRecomp) ...[
                const SizedBox(height: 24),
                const Divider(color: AppTheme.bg3),
                const SizedBox(height: 16),
                Text('Body Metrics', style: theme.textTheme.titleSmall?.copyWith(color: AppTheme.txt0)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _RecompChartPainter(data.bodyComposition, data.weightTrend.rawPoints),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // --- Stratum 3: Strength & Volume ---
  Widget _buildStratum3(ThemeData theme, ProgressReportData data) {
    if (data.effectiveSets.isEmpty && data.e1rmData.isEmpty) {
      return _buildCollapsedSection(theme, 'STRENGTH & VOLUME', 'Complete workouts to track sets and strength trends.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STRENGTH & VOLUME', style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.txt2, letterSpacing: 1.0)),
        const SizedBox(height: 12),
        if (data.effectiveSets.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.bg1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.bg3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Effective Sets per Muscle', style: theme.textTheme.titleSmall?.copyWith(color: AppTheme.txt0)),
                const SizedBox(height: 16),
                SizedBox(
                  height: max(100.0, data.effectiveSets.length * 24.0),
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _EffectiveSetsChartPainter(data.effectiveSets),
                  ),
                ),
              ],
            ),
          ),
        if (data.e1rmData.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bg1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.bg3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estimated 1RM Trend', style: theme.textTheme.titleSmall?.copyWith(color: AppTheme.txt0)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _E1rmChartPainter(data.e1rmData),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: List.generate(data.e1rmData.length, (i) {
                    final colors = [AppTheme.amber, AppTheme.coral, AppTheme.green];
                    final color = colors[i % colors.length];
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text(data.e1rmData[i].exerciseName, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.txt1)),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // --- Stratum 4: Details & Alerts ---
  Widget _buildStratum4(ThemeData theme, ProgressReportData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DETAILS & ALERTS', style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.txt2, letterSpacing: 1.0)),
        const SizedBox(height: 12),
        if (data.alerts.isNotEmpty)
          ...data.alerts.map((alert) => _buildAlertRow(theme, alert)),
        if (data.alerts.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('No active alerts.', style: TextStyle(color: AppTheme.txt2, fontStyle: FontStyle.italic)),
          ),
        
        const SizedBox(height: 12),
        if (data.prs.isNotEmpty) ...[
          Text('Personal Records', style: theme.textTheme.titleSmall?.copyWith(color: AppTheme.txt0)),
          const SizedBox(height: 8),
          ...data.prs.map((pr) => _buildPRRow(theme, pr)),
          const SizedBox(height: 16),
        ],

        if (data.sessionNotes.isNotEmpty) ...[
          Text('Athlete Notes', style: theme.textTheme.titleSmall?.copyWith(color: AppTheme.txt0)),
          const SizedBox(height: 8),
          ...data.sessionNotes.map((note) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.bg1,
              borderRadius: BorderRadius.circular(8),
              border: Border(left: BorderSide(color: AppTheme.bg3, width: 3)),
            ),
            child: Text('"$note"', style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt1, fontStyle: FontStyle.italic)),
          )),
        ],
      ],
    );
  }

  Widget _buildAlertRow(ThemeData theme, AlertData alert) {
    final isWarning = alert.severity == AlertSeverity.warning;
    final color = isWarning ? AppTheme.coral : AppTheme.green;
    final icon = isWarning ? Icons.warning_amber_rounded : Icons.check_circle_outline;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bg1,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(alert.text, style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt0))),
        ],
      ),
    );
  }

  Widget _buildPRRow(ThemeData theme, PR pr) {
    final format = DateFormat('MMM d');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppTheme.amber.withValues(alpha: 0.3)),
            ),
            child: Text('PR', style: AppTheme.monoSmall(color: AppTheme.amber).copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(pr.exerciseName, style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt0))),
          Text('${pr.weight}kg × ${pr.reps}', style: AppTheme.monoMedium(color: AppTheme.txt0)),
          const SizedBox(width: 8),
          Text(format.format(pr.date), style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.txt2)),
        ],
      ),
    );
  }

  Widget _buildCollapsedSection(ThemeData theme, String title, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.txt2, letterSpacing: 1.0)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bg1.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.bg2, style: BorderStyle.solid),
          ),
          child: Text(hint, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.txt2, fontStyle: FontStyle.italic)),
        ),
      ],
    );
  }
}

// ==========================================
// CUSTOM PAINTERS FOR CHARTS
// ==========================================

class _WeightChartPainter extends CustomPainter {
  final WeightTrendData data;
  _WeightChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.rawPoints.isEmpty) return;

    final paintRaw = Paint()
      ..color = AppTheme.txt2.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
      
    final paintTrend = Paint()
      ..color = AppTheme.amber
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double minWt = data.rawPoints.map((e) => e.value).reduce(min);
    double maxWt = data.rawPoints.map((e) => e.value).reduce(max);
    if (maxWt - minWt < 2) {
      minWt -= 1; maxWt += 1; // padding
    }

    int minTime = data.rawPoints.first.date.millisecondsSinceEpoch;
    int maxTime = data.rawPoints.last.date.millisecondsSinceEpoch;
    if (maxTime == minTime) maxTime += 86400000;

    double x(int t) => (t - minTime) / (maxTime - minTime) * size.width;
    double y(double v) => size.height - ((v - minWt) / (maxWt - minWt) * size.height);

    // Draw raw points
    for (var p in data.rawPoints) {
      canvas.drawCircle(Offset(x(p.date.millisecondsSinceEpoch), y(p.value)), 3, paintRaw);
    }

    // Draw trend line
    if (data.isSparse) {
      // Degraded simple line
      final p1 = data.rawPoints.first;
      final p2 = data.rawPoints.last;
      canvas.drawLine(
        Offset(x(p1.date.millisecondsSinceEpoch), y(p1.value)),
        Offset(x(p2.date.millisecondsSinceEpoch), y(p2.value)),
        paintTrend..color = AppTheme.txt2,
      );
    } else if (data.trendPoints.isNotEmpty) {
      final path = Path();
      bool first = true;
      for (var p in data.trendPoints) {
        if (first) {
          path.moveTo(x(p.date.millisecondsSinceEpoch), y(p.value));
          first = false;
        } else {
          path.lineTo(x(p.date.millisecondsSinceEpoch), y(p.value));
        }
      }
      canvas.drawPath(path, paintTrend);
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) => true;
}

class _RecompChartPainter extends CustomPainter {
  final List<BodyCompositionSeries> seriesList;
  final List<DataPoint> timeRef; // to synchronize x axis

  _RecompChartPainter(this.seriesList, this.timeRef);

  @override
  void paint(Canvas canvas, Size size) {
    if (seriesList.isEmpty || timeRef.isEmpty) return;
    
    int minTime = timeRef.first.date.millisecondsSinceEpoch;
    int maxTime = timeRef.last.date.millisecondsSinceEpoch;
    if (maxTime == minTime) maxTime += 86400000;

    double x(int t) => (t - minTime) / (maxTime - minTime) * size.width;

    final colors = [AppTheme.coral, AppTheme.green, AppTheme.amber];
    
    for (int i = 0; i < seriesList.length; i++) {
      final series = seriesList[i];
      if (series.points.isEmpty) continue;
      
      double minV = series.points.map((e) => e.value).reduce(min);
      double maxV = series.points.map((e) => e.value).reduce(max);
      if (maxV == minV) { minV -= 1; maxV += 1; }
      double y(double v) => size.height - ((v - minV) / (maxV - minV) * size.height);

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path();
      bool first = true;
      for (var p in series.points) {
        if (first) {
          path.moveTo(x(p.date.millisecondsSinceEpoch), y(p.value));
          first = false;
        } else {
          path.lineTo(x(p.date.millisecondsSinceEpoch), y(p.value));
        }
      }
      canvas.drawPath(path, paint);
      
      // Draw label
      final textSpan = TextSpan(
        text: series.metricName,
        style: TextStyle(color: paint.color, fontSize: 10),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, i * 14.0));
    }
  }

  @override
  bool shouldRepaint(covariant _RecompChartPainter oldDelegate) => true;
}

class _EffectiveSetsChartPainter extends CustomPainter {
  final List<EffectiveSetCount> data;
  _EffectiveSetsChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    int maxCount = data.map((e) => e.count).reduce(max);
    maxCount = max(25, maxCount); // ensure MEV/MRV (10, 20) are visible

    double x(int count) => (count / maxCount) * size.width;
    double barHeight = 12.0;
    double spacing = 24.0; // Y spacing per item

    final paintBar = Paint()
      ..color = AppTheme.amber
      ..style = PaintingStyle.fill;
    
    final paintRef = Paint()
      ..color = AppTheme.txt2.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw reference lines
    for (int ref in [10, 20]) {
      if (ref > maxCount) continue;
      double refX = x(ref);
      canvas.drawLine(Offset(refX, 0), Offset(refX, size.height), paintRef);
      // ref label
      final tp = TextPainter(
        text: TextSpan(text: ref == 10 ? 'MEV(10)' : 'MRV(20)', style: const TextStyle(color: AppTheme.txt2, fontSize: 8)),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(refX + 2, 0));
    }

    // Draw bars
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      double y = i * spacing + 12;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, y, x(item.count), barHeight), const Radius.circular(4)),
        paintBar,
      );
      
      // Label
      final tp = TextPainter(
        text: TextSpan(text: '${item.bodyPart} (${item.count})', style: const TextStyle(color: AppTheme.txt0, fontSize: 10)),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x(item.count) + 6, y - 1));
    }
  }

  @override
  bool shouldRepaint(covariant _EffectiveSetsChartPainter oldDelegate) => true;
}

class _E1rmChartPainter extends CustomPainter {
  final List<E1rmSeries> data;
  _E1rmChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    int minTime = data.expand((s) => s.points).map((p) => p.date.millisecondsSinceEpoch).reduce(min);
    int maxTime = data.expand((s) => s.points).map((p) => p.date.millisecondsSinceEpoch).reduce(max);
    if (maxTime == minTime) maxTime += 86400000;

    double x(int t) => (t - minTime) / (maxTime - minTime) * size.width;
    
    final colors = [AppTheme.amber, AppTheme.coral, AppTheme.green];

    for (int i = 0; i < data.length; i++) {
      final series = data[i];
      if (series.points.isEmpty) continue;

      double minV = series.points.map((e) => e.value).reduce(min);
      double maxV = series.points.map((e) => e.value).reduce(max);
      if (maxV == minV) { minV -= 1; maxV += 1; }
      double y(double v) => size.height - ((v - minV) / (maxV - minV) * size.height);

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path();
      bool first = true;
      for (var p in series.points) {
        if (first) {
          path.moveTo(x(p.date.millisecondsSinceEpoch), y(p.value));
          first = false;
        } else {
          path.lineTo(x(p.date.millisecondsSinceEpoch), y(p.value));
        }
      }
      canvas.drawPath(path, paint);
      
      // Draw end dot
      final last = series.points.last;
      canvas.drawCircle(Offset(x(last.date.millisecondsSinceEpoch), y(last.value)), 4, Paint()..color = paint.color);
    }
  }

  @override
  bool shouldRepaint(covariant _E1rmChartPainter oldDelegate) => true;
}
