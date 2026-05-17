import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../workout/domain/entities/routine_exercise_detail.dart';
import '../../../workout/presentation/widgets/body_part_tag.dart';
import '../../domain/entities/program_day.dart';

String getDominantBodyPart(List<RoutineExerciseDetail> exercises) {
  if (exercises.isEmpty) return 'default';
  final counts = <String, int>{};
  for (final ex in exercises) {
    counts[ex.bodyPart] = (counts[ex.bodyPart] ?? 0) + 1;
  }
  return counts.entries
      .reduce((a, b) => a.value >= b.value ? a : b)
      .key;
}

class CycleProgressStrip extends StatefulWidget {
  final List<ProgramDay> days;
  final int currentDayIndex;
  final Set<int> completedDayIndices;
  final Map<int, String>? dayBodyParts;

  const CycleProgressStrip({
    super.key,
    required this.days,
    required this.currentDayIndex,
    required this.completedDayIndices,
    this.dayBodyParts,
  });

  @override
  State<CycleProgressStrip> createState() => _CycleProgressStripState();
}

class _CycleProgressStripState extends State<CycleProgressStrip> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    if (widget.days.length > 7) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final offset = (widget.currentDayIndex * (36 + 8)) -
              (MediaQuery.of(context).size.width / 2) +
              18;
          _scrollController.animateTo(
            offset.clamp(0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.days.isEmpty) return const SizedBox.shrink();

    final children = List.generate(widget.days.length, (i) {
      final day = widget.days[i];
      final isCurrent = i == widget.currentDayIndex;
      final isCompleted = widget.completedDayIndices.contains(i);
      final isRest = day.label.toLowerCase() == 'rest';
      final bodyPart = widget.dayBodyParts?[i] ?? 'default';

      final Widget pill = Container(
        width: 36,
        height: 36,
        margin: EdgeInsets.only(right: i < widget.days.length - 1 ? 8 : 0),
        child: _buildPill(day, isCurrent, isCompleted, isRest, bodyPart),
      );

      if (isCurrent) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            pill,
            const SizedBox(height: 4),
            Container(
              width: 4,
              height: 4,
              margin: EdgeInsets.only(right: i < widget.days.length - 1 ? 8 : 0),
              decoration: const BoxDecoration(
                color: AppTheme.amber,
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      } else {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            pill,
            const SizedBox(height: 8), // Matching the space for the dot
          ],
        );
      }
    });

    if (widget.days.length <= 7) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    } else {
      return SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );
    }
  }

  Widget _buildPill(
    ProgramDay day,
    bool isCurrent,
    bool isCompleted,
    bool isRest,
    String bodyPart,
  ) {
    final colors = BodyPartTag.getColors(bodyPart);
    final accentColor = colors.$2;

    if (isRest) {
      if (isCompleted) {
        return CustomPaint(
          painter: DashedCirclePainter(
            color: AppTheme.green.withValues(alpha: 0.5),
            strokeWidth: 1.5,
          ),
          child: Center(
            child: Icon(Icons.check, size: 16, color: AppTheme.green.withValues(alpha: 0.5)),
          ),
        );
      } else {
        return CustomPaint(
          painter: DashedCirclePainter(
            color: AppTheme.bg3,
            strokeWidth: 1.5,
          ),
          child: const Center(
            child: Text('R', style: TextStyle(color: AppTheme.txt3, fontSize: 12)),
          ),
        );
      }
    }

    if (isCompleted) {
      return Container(
        decoration: const BoxDecoration(
          color: AppTheme.green,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.check, size: 16, color: Colors.white),
      );
    }

    final letter = day.label.isNotEmpty ? day.label[0].toUpperCase() : '?';
    final bgColor = accentColor.withValues(alpha: 0.8);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: isCurrent ? Border.all(color: AppTheme.amber, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  DashedCirclePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    const dashLength = 4.0;
    const dashSpace = 3.0;
    final circumference = 2 * math.pi * radius;
    final dashCount = (circumference / (dashLength + dashSpace)).floor();

    for (var i = 0; i < dashCount; i++) {
      final startAngle = (i * (dashLength + dashSpace)) / radius;
      final sweepAngle = dashLength / radius;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
