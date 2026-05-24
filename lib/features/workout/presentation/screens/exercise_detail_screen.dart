import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/theme.dart';
import '../controllers/workout_providers.dart';
import '../../domain/entities/exercise_history_summary.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  final int exerciseId;

  const ExerciseDetailScreen({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(exerciseHistoryProvider(exerciseId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.bg0,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text('Exercise History', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
        data: (summary) {
          if (summary.volumeHistory.isEmpty) {
            return const Center(child: Text('No history found for this exercise.'));
          }

          final bestStr = summary.allTimeBest != null
              ? '${summary.allTimeBest!.weight.toStringAsFixed(0)} ${summary.exercise.weightUnit} × ${summary.allTimeBest!.reps}'
              : 'N/A';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.exercise.name,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.txt1),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'All-time best: $bestStr',
                        style: AppTheme.monoMedium(color: AppTheme.amber).copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                
                // Chart
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: SizedBox(
                    height: 200,
                    child: CustomPaint(
                      painter: _VolumeChartPainter(summary.volumeHistory, theme),
                    ),
                  ),
                ),

                // Stats Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          title: 'Total Sessions',
                          value: summary.recentSessions.length.toString(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatBox(
                          title: 'Max Weight',
                          value: summary.allTimeBest != null ? '${summary.allTimeBest!.weight.toStringAsFixed(0)} ${summary.exercise.weightUnit}' : 'N/A',
                        ),
                      ),
                    ],
                  ),
                ),

                // History List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Text('Recent Sessions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.txt1)),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: summary.recentSessions.length,
                  itemBuilder: (context, index) {
                    final session = summary.recentSessions[index];
                    final date = DateTime.fromMillisecondsSinceEpoch(session.startTimestamp);
                    final volumeItem = summary.volumeHistory.firstWhere((v) => v.sessionId == session.id, orElse: () => const SessionVolume(sessionId: 0, timestamp: 0, volume: 0, hasPR: false));

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                      title: Text(DateFormat('MMM d, yyyy').format(date), style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt1)),
                      subtitle: Text(session.routineNameSnapshot, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.txt2)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${volumeItem.volume.toStringAsFixed(0)} ${summary.exercise.weightUnit}', style: AppTheme.monoMedium(color: AppTheme.txt1)),
                          if (volumeItem.hasPR)
                            Text('★ PR', style: AppTheme.monoSmall(color: AppTheme.amber)),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String value;

  const _StatBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bg1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.monoSmall(color: AppTheme.txt2)),
          const SizedBox(height: 8),
          Text(value, style: AppTheme.monoMedium(color: AppTheme.txt1).copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _VolumeChartPainter extends CustomPainter {
  final List<SessionVolume> data;
  final ThemeData theme;

  _VolumeChartPainter(this.data, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paintLine = Paint()
      ..color = theme.colorScheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintDot = Paint()
      ..color = AppTheme.bg0
      ..style = PaintingStyle.fill;

    final paintDotStroke = Paint()
      ..color = theme.colorScheme.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paintPR = Paint()
      ..color = AppTheme.amber
      ..style = PaintingStyle.fill;

    final minVol = data.map((e) => e.volume).reduce((a, b) => a < b ? a : b);
    final maxVol = data.map((e) => e.volume).reduce((a, b) => a > b ? a : b);
    final volRange = maxVol == minVol ? 1.0 : (maxVol - minVol);

    final dx = data.length > 1 ? size.width / (data.length - 1) : size.width / 2;
    final pts = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = data.length > 1 ? i * dx : dx;
      final normalizedY = (data[i].volume - minVol) / volRange;
      final y = size.height - (normalizedY * size.height * 0.8) - (size.height * 0.1); // 10% padding top/bottom
      pts.add(Offset(x, y));
    }

    // Draw line
    if (pts.length > 1) {
      final path = Path();
      path.moveTo(pts[0].dx, pts[0].dy);
      for (int i = 1; i < pts.length; i++) {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
      canvas.drawPath(path, paintLine);
    }

    // Draw dots and labels
    final textStyle = AppTheme.monoSmall(color: AppTheme.txt1).copyWith(fontSize: 10);
    for (int i = 0; i < pts.length; i++) {
      final p = pts[i];
      final item = data[i];

      if (item.hasPR) {
        canvas.drawCircle(p, 6, paintPR);
      } else {
        canvas.drawCircle(p, 5, paintDot);
        canvas.drawCircle(p, 5, paintDotStroke);
      }

      // Draw volume label
      final textPainter = TextPainter(
        text: TextSpan(text: item.volume.toStringAsFixed(0), style: textStyle),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(p.dx - textPainter.width / 2, p.dy - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
