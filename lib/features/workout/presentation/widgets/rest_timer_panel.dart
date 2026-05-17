import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../controllers/workout_providers.dart';

final restTimerDurationProvider = StateProvider<int?>((ref) => null);

class _AnimatedPRBadgePill extends StatefulWidget {
  const _AnimatedPRBadgePill();

  @override
  State<_AnimatedPRBadgePill> createState() => _AnimatedPRBadgePillState();
}

class _AnimatedPRBadgePillState extends State<_AnimatedPRBadgePill> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.12).chain(CurveTween(curve: Curves.easeOut)), weight: 250),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 250),
    ]).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.amber.withValues(alpha: 0.09),
          border: Border.all(color: AppTheme.amber.withValues(alpha: 0.27)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, size: 11, color: AppTheme.amber),
            SizedBox(width: 4),
            Text('New PR!', style: TextStyle(color: AppTheme.amber, fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class RestTimerPanel extends ConsumerStatefulWidget {
  const RestTimerPanel({super.key});

  @override
  ConsumerState<RestTimerPanel> createState() => _RestTimerPanelState();
}

class _RestTimerPanelState extends ConsumerState<RestTimerPanel> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int? _currentDuration;
  bool _isVisible = false;
  int? _lastRemaining;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _progressController = AnimationController(
      vsync: this,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressController.addListener(_onProgressUpdate);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _progressController.removeListener(_onProgressUpdate);
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onProgressUpdate() {
    if (_currentDuration == null) return;
    final remaining = (_currentDuration! * (1.0 - _progressController.value)).ceil();
    
    if (_lastRemaining != remaining) {
      _lastRemaining = remaining;
      if (remaining <= 10 && remaining > 0) {
        HapticFeedback.lightImpact();
      }
    }

    if (remaining <= 0 && _isVisible) {
      HapticFeedback.mediumImpact();
      _dismissTimer(isUserDismissed: false);
    } else if (remaining <= 10 && remaining > 0) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.value = 0;
      }
    }
  }

  void _dismissTimer({bool isUserDismissed = true}) {
    if (isUserDismissed) {
      HapticFeedback.lightImpact();
    }
    _slideController.reverse().then((_) {
      if (mounted) {
        setState(() => _isVisible = false);
        ref.read(restTimerDurationProvider.notifier).state = null;
        _pulseController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int?>(restTimerDurationProvider, (previous, next) {
      if (next != null) {
        _currentDuration = next;
        _progressController.duration = Duration(seconds: next);
        _lastRemaining = null;
        _progressController.forward(from: 0.0);
        setState(() => _isVisible = true);
        _slideController.forward();
      } else {
        _dismissTimer(isUserDismissed: false);
      }
    });

    if (!_isVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut)),
        child: GestureDetector(
          onTap: () => _dismissTimer(isUserDismissed: true),
          child: AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              final progress = _progressController.value;
              final remaining = _currentDuration != null ? (_currentDuration! * (1.0 - progress)).ceil() : 0;
              final isUrgent = remaining <= 10;
              
              final backgroundColor = isUrgent 
                  ? theme.colorScheme.tertiary.withValues(alpha: 0.94)
                  : theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.96);

              final arcColor = isUrgent ? theme.colorScheme.tertiary : theme.colorScheme.primary;
              final textColor = isUrgent ? theme.colorScheme.tertiary : theme.colorScheme.primary;

              return Container(
                height: 80,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(48, 48),
                            painter: _ArcProgressPainter(
                              progress: progress,
                              trackColor: theme.colorScheme.surfaceContainerHighest,
                              arcColor: arcColor,
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: isUrgent ? _pulseAnimation.value : 1.0,
                                child: Text(
                                  '$remaining',
                                  style: AppTheme.monoLarge(color: textColor).copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Rest',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Builder(builder: (context) {
                                final activeState = ref.watch(workoutSessionNotifierProvider).valueOrNull;
                                if (activeState?.lastPRSetId != null) {
                                  return const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: _AnimatedPRBadgePill(),
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
                            ],
                          ),
                          Builder(builder: (context) {
                            final activeState = ref.watch(workoutSessionNotifierProvider).valueOrNull;
                            if (activeState?.lastPRSetId != null) {
                              final prSet = activeState!.sets.cast<dynamic>().firstWhere(
                                (s) => s.id == activeState.lastPRSetId,
                                orElse: () => null,
                              );
                              final exerciseDetail = activeState.activeExercises.cast<dynamic>().firstWhere(
                                (e) => e.exerciseId == prSet?.exerciseId,
                                orElse: () => null,
                              );
                              if (prSet != null && exerciseDetail != null) {
                                final weightText = exerciseDetail.weightUnit == 'plates' 
                                    ? prSet.weight.toStringAsFixed(0) 
                                    : prSet.weight.toString();
                                return Text(
                                  '$weightText${exerciseDetail.weightUnit} × ${prSet.reps} — your best ever',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                    color: AppTheme.amber,
                                  ),
                                );
                              }
                            }
                            return Text(
                              'Set logged · Tap to skip',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    Text(
                      'Skip',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.skip_next, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ArcProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color arcColor;

  _ArcProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.arcColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 1.5;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, radius, trackPaint);

    final arcPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * (1.0 - progress);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_ArcProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.arcColor != arcColor;
  }
}
