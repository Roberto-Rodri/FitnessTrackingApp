import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/theme.dart';
import '../../../workout/presentation/controllers/body_weight_providers.dart';
import '../../../workout/presentation/widgets/log_weight_sheet.dart';

class BodyWeightScreen extends ConsumerWidget {
  const BodyWeightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logsAsync = ref.watch(bodyWeightLogsNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg0,
      appBar: AppBar(
        backgroundColor: AppTheme.bg0,
        elevation: 0,
        title: Text(
          'BODY WEIGHT',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppTheme.txt1,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.txt1),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const LogWeightSheet(),
          );
        },
        backgroundColor: AppTheme.amber,
        child: const Icon(Icons.add, color: AppTheme.bg0),
      ),
      body: logsAsync.when(
        data: (logs) {
          return Column(
            children: [
              // Header Chart/Trend
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bg1,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.bg3),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'TREND',
                      style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.txt2, letterSpacing: 0.06),
                    ),
                    const SizedBox(height: 16),
                    if (logs.isEmpty)
                      const Text('No data yet', style: TextStyle(color: AppTheme.txt2))
                    else
                      SizedBox(
                        height: 100,
                        child: CustomPaint(
                          painter: _TrendChartPainter(
                            points: logs.reversed.map((l) => l.weight).toList(),
                            color: AppTheme.amber,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: logs.isEmpty 
                  ? Center(
                      child: Text(
                        'No logs yet.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt2),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        return Dismissible(
                          key: Key(log.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: theme.colorScheme.error,
                            child: const Icon(Icons.delete, color: AppTheme.bg0),
                          ),
                          onDismissed: (_) {
                            ref.read(bodyWeightLogsNotifierProvider.notifier).deleteLog(log.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: AppTheme.bg3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('MMM d, yyyy').format(log.date),
                                  style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt2),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      log.weight.toStringAsFixed(1),
                                      style: AppTheme.monoLarge(color: AppTheme.txt1).copyWith(fontSize: 20),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'kg',
                                      style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.txt3),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  final List<double> points;
  final Color color;

  _TrendChartPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final maxVal = points.reduce((a, b) => a > b ? a : b);
    final minVal = points.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final stepX = size.width / (points.length - 1);
    final path = Path();

    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      // Invert Y axis: higher value = lower Y
      final y = size.height - ((points[i] - minVal) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = color..style = PaintingStyle.fill);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) => true;
}
