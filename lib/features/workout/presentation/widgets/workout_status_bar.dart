import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class WorkoutStatusBar extends StatefulWidget {
  final VoidCallback onFinish;
  final int? startTimestamp; // ms since epoch

  const WorkoutStatusBar({
    super.key,
    required this.onFinish,
    this.startTimestamp,
  });

  @override
  State<WorkoutStatusBar> createState() => _WorkoutStatusBarState();
}

class _WorkoutStatusBarState extends State<WorkoutStatusBar> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateElapsed();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateElapsed();
    });
  }

  void _updateElapsed() {
    if (widget.startTimestamp == null) return;
    final start = DateTime.fromMillisecondsSinceEpoch(widget.startTimestamp!);
    setState(() {
      _elapsed = DateTime.now().difference(start);
    });
  }

  @override
  void didUpdateWidget(WorkoutStatusBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If a new session starts while the widget is mounted, reset immediately.
    if (oldWidget.startTimestamp != widget.startTimestamp) {
      _updateElapsed();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatElapsed(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elapsedText = widget.startTimestamp != null
        ? _formatElapsed(_elapsed)
        : '--:--';

    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Elapsed Time
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: AppTheme.txt2, size: 20),
                const SizedBox(width: 8),
                Text(
                  elapsedText,
                  style: AppTheme.monoMedium(color: AppTheme.txt1),
                ),
              ],
            ),

            // Finish Button
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              onPressed: widget.onFinish,
              icon: const Icon(Icons.check, size: 20),
              label: const Text(
                'Finish',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            // Rest Time (placeholder / linked to rest timer)
            Row(
              children: [
                Icon(Icons.pause_circle_outline, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  '00:00',
                  style: AppTheme.monoMedium(color: theme.colorScheme.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
