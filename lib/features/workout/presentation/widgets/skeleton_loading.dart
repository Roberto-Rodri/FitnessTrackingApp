import 'package:flutter/material.dart';

class Bone extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const Bone({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 7.0,
  });

  @override
  State<Bone> createState() => _BoneState();
}

class _BoneState extends State<Bone> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg3 = theme.colorScheme.outline; // #3D352C
    final bg2 = theme.colorScheme.surfaceContainerHigh; // #2E2923

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: [bg3, bg2, bg3],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: _SlidingGradientTransform(_controller.value),
            ),
          ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 2 - 1),
      0.0,
      0.0,
    );
  }
}

class SkeletonHistoryCard extends StatelessWidget {
  const SkeletonHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Bone(width: 140, height: 14),
              Spacer(),
              Bone(width: 80, height: 12),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Bone(width: 60, height: 12),
              SizedBox(width: 12),
              Bone(width: 60, height: 12),
              SizedBox(width: 12),
              Bone(width: 80, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

class SkeletonStatPill extends StatelessWidget {
  const SkeletonStatPill({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FractionallySizedBox(
            widthFactor: 0.55,
            alignment: Alignment.centerLeft,
            child: Bone(width: double.infinity, height: 10),
          ),
          SizedBox(height: 8),
          FractionallySizedBox(
            widthFactor: 0.70,
            alignment: Alignment.centerLeft,
            child: Bone(width: double.infinity, height: 22),
          ),
        ],
      ),
    );
  }
}

class SkeletonRoutineCard extends StatelessWidget {
  const SkeletonRoutineCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: const Row(
        children: [
          Bone(width: 40, height: 40, borderRadius: 12),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Bone(width: 120, height: 14),
              SizedBox(height: 6),
              Bone(width: 180, height: 12),
            ],
          ),
          Spacer(),
          Bone(width: 8, height: 16),
        ],
      ),
    );
  }
}

class SkeletonExerciseRow extends StatelessWidget {
  const SkeletonExerciseRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Bone(width: 180, height: 14),
          Spacer(),
          Bone(width: 60, height: 24, borderRadius: 12),
        ],
      ),
    );
  }
}
