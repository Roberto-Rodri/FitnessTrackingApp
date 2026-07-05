import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/workout_set.dart';
import 'exercise_swap_sheet.dart';
import 'quick_swap_sheet.dart';
import '../../../../core/theme/theme.dart';
import 'body_part_tag.dart';
import '../../domain/entities/exercise.dart';
import '../controllers/workout_providers.dart';
import 'pr_badge.dart';
import 'comparison_panel.dart';
import '../../../profile/presentation/controllers/profile_providers.dart';
import '../../../profile/domain/entities/user_profile.dart';

class _AnimatedSetRow extends StatefulWidget {
  final Widget child;

  const _AnimatedSetRow({required this.child});

  @override
  State<_AnimatedSetRow> createState() => _AnimatedSetRowState();
}

class _AnimatedSetRowState extends State<_AnimatedSetRow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _colorAnim;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _colorAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnim,
      builder: (context, child) {
        return Container(
          color: AppTheme.amber.withValues(alpha: 0.13 * _colorAnim.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _AnimatedPRBadge extends StatefulWidget {
  final PRBadgeSize size;
  const _AnimatedPRBadge({required this.size});

  @override
  State<_AnimatedPRBadge> createState() => _AnimatedPRBadgeState();
}

class _AnimatedPRBadgeState extends State<_AnimatedPRBadge> {
  bool _startAnim = false;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.lightImpact();
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _startAnim = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_startAnim) {
      return Transform.scale(scale: 0.0, child: PRBadge(size: widget.size));
    }
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: PRBadge(size: widget.size),
    );
  }
}

class ActiveExerciseCard extends ConsumerStatefulWidget {
  final int exerciseId;
  final String exerciseName;
  final String targetSetsAndReps;
  final List<WorkoutSet> completedSets;
  final String weightUnit;
  final String bodyPart;
  final Map<String, dynamic>? bestSet;
  final Map<String, dynamic>? latestSetGlobal;
  final Map<String, dynamic>? latestSetRoutine;
  final bool useRoutineLatest;
  final List<Exercise>? alternatives;

  const ActiveExerciseCard({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.targetSetsAndReps,
    required this.completedSets,
    required this.weightUnit,
    required this.bodyPart,
    this.bestSet,
    this.latestSetGlobal,
    this.latestSetRoutine,
    required this.useRoutineLatest,
    this.alternatives,
  });

  @override
  ConsumerState<ActiveExerciseCard> createState() => _ActiveExerciseCardState();
}

class _ActiveExerciseCardState extends ConsumerState<ActiveExerciseCard> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final FocusNode _weightFocus = FocusNode();
  final FocusNode _repsFocus = FocusNode();
  bool _showExtraSetInput = false;
  bool _isWarmupActive = false;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final profile = ref.read(userProfileControllerProvider).value;
      if (profile != null && !profile.hasSeenWarmupHint) {
        await ref.read(userProfileControllerProvider.notifier).markWarmupHintSeen();
        if (mounted) {
          setState(() => _showHint = true);
          Future.delayed(const Duration(seconds: 6), () {
            if (mounted) setState(() => _showHint = false);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _weightFocus.dispose();
    _repsFocus.dispose();
    super.dispose();
  }

  Future<void> _logSet() async {
    final weightStr = _weightController.text;
    final repsStr = _repsController.text;

    if (weightStr.isEmpty || repsStr.isEmpty) {
      return; 
    }

    double? weight;
    String? customWeight;

    if (widget.weightUnit == 'custom') {
      weight = 0.0;
      customWeight = weightStr;
    } else {
      weight = double.tryParse(weightStr);
    }

    final reps = int.tryParse(repsStr);

    if (weight == null || reps == null) {
      return; 
    }

    final newSet = WorkoutSet(
      sessionId: -1,
      exerciseId: widget.exerciseId,
      weight: weight,
      reps: reps,
      customWeight: customWeight,
      isWarmup: _isWarmupActive,
    );

    try {
      await ref.read(workoutSessionControllerProvider.notifier).logNewSet(newSet);
      HapticFeedback.mediumImpact();
      if (mounted) {
        _weightController.clear();
        _repsController.clear();
        _weightFocus.requestFocus();
        setState(() {
          _showExtraSetInput = false;
          _isWarmupActive = false;
        });
      }
    } catch (_) {}
  }

  void _editSet(WorkoutSet set) {
    showDialog(
      context: context,
      builder: (context) {
        return _EditSetDialog(
          set: set,
          weightUnit: widget.weightUnit,
          onSave: (double? newWeight, int newReps, String? newCustomWeight) async {
            try {
              final newSet = set.copyWith(
                weight: newWeight ?? 0.0,
                reps: newReps,
                customWeight: newCustomWeight,
              );
              await ref.read(workoutSessionControllerProvider.notifier).updateSet(newSet);
            } catch (e) {
              // Ignore
            }
          },
          onDelete: () async {
            try {
              await ref.read(workoutSessionControllerProvider.notifier).deleteSet(set.id!);
            } catch (e) {
              // Ignore
            }
          },
        );
      },
    );
  }

  String _formatWeight(Map<String, dynamic> setMap) {
    if (widget.weightUnit == 'custom') {
      return setMap['customWeight'] as String? ?? '';
    } else if (widget.weightUnit == 'plates') {
      final w = (setMap['weight'] as num?)?.toDouble() ?? 0;
      return '${w.toStringAsFixed(0)} plates';
    } else {
      final w = (setMap['weight'] as num?)?.toDouble() ?? 0;
      return '${w.toStringAsFixed(w.truncateToDouble() == w ? 0 : 1)} ${widget.weightUnit}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(userProfileControllerProvider);
    final phase = profileAsync.value?.phase ?? TrainingPhase.none;

    final targetSets = int.tryParse(widget.targetSetsAndReps.split('×').first.trim()) ?? 3;
    final targetRepsStr = widget.targetSetsAndReps.contains('×') 
        ? widget.targetSetsAndReps.split('×').last.trim() 
        : widget.targetSetsAndReps;
    
    int? rangeBottom;
    int? rangeTop;
    if (targetRepsStr.contains('-')) {
      rangeBottom = int.tryParse(targetRepsStr.split('-').first.trim());
      rangeTop = int.tryParse(targetRepsStr.split('-').last.trim());
    } else {
      rangeBottom = int.tryParse(targetRepsStr);
      rangeTop = rangeBottom;
    }

    final currentSetNum = widget.completedSets.length + 1;

    final latestSet = widget.useRoutineLatest 
        ? (widget.latestSetRoutine ?? widget.latestSetGlobal)
        : widget.latestSetGlobal;

    final latestLabel = (widget.useRoutineLatest && widget.latestSetRoutine == null && widget.latestSetGlobal != null)
        ? 'Last (all)'
        : 'Last';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 8, top: 16, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.exerciseName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          BodyPartTag(bodyPart: widget.bodyPart),
                          const SizedBox(width: 8),
                          Text(
                            'Set $currentSetNum of $targetSets · Target ${widget.targetSetsAndReps}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.txt2,
                            ),
                          ),
                        ],
                      ),
                      if (widget.bestSet != null || latestSet != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (widget.bestSet != null && widget.bestSet!['reps'] != null)
                              Text.rich(TextSpan(children: [
                                TextSpan(text: 'Best: ', style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.txt2, fontSize: 12)),
                                TextSpan(
                                  text: '${_formatWeight(widget.bestSet!)} × ${widget.bestSet!['reps']}', 
                                  style: AppTheme.monoSmall(color: AppTheme.amber).copyWith(fontSize: 12),
                                ),
                              ])),
                            if (widget.bestSet != null && latestSet != null && widget.bestSet!['reps'] != null && latestSet['reps'] != null)
                              Text('  ·  ', style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.txt3)),
                            if (latestSet != null && latestSet['reps'] != null)
                              Text.rich(TextSpan(children: [
                                TextSpan(text: '$latestLabel: ', style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.txt2, fontSize: 12)),
                                TextSpan(
                                  text: '${_formatWeight(latestSet)} × ${latestSet['reps']}',
                                  style: AppTheme.monoSmall(color: AppTheme.amber).copyWith(fontSize: 12),
                                ),
                              ])),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.bar_chart, color: theme.colorScheme.onSurfaceVariant),
                      onPressed: () {
                        context.pushNamed(RouteNames.exerciseDetail, pathParameters: {'id': widget.exerciseId.toString()});
                      },
                    ),
                    InkWell(
                  onTap: () async {
                    void showFullSwapSheet() {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => ExerciseSwapSheet(
                          currentExerciseId: widget.exerciseId,
                          onExerciseSelected: (newExercise) {
                            ref.read(workoutSessionControllerProvider.notifier)
                                .swapExercise(widget.exerciseId, newExercise);
                          },
                        ),
                      );
                    }

                    final alts = widget.alternatives;
                    if (alts != null && alts.isNotEmpty) {
                      final result = await showModalBottomSheet<dynamic>(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => QuickSwapSheet(
                          alternatives: alts,
                        ),
                      );

                      if (result == 'SHOW_MORE') {
                        if (mounted) showFullSwapSheet();
                      } else if (result is Exercise) {
                        ref.read(workoutSessionControllerProvider.notifier)
                            .swapExercise(widget.exerciseId, result);
                      }
                    } else {
                      showFullSwapSheet();
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.swap_horiz, color: AppTheme.txt2, size: 20),
                  ),
                  ),
                  ],
                ),
              ],
            ),
          ),

          // Completed Sets
          ...widget.completedSets.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final set = entry.value;
            final weightText = widget.weightUnit == 'custom'
                ? (set.customWeight ?? '')
                : (widget.weightUnit == 'plates' ? set.weight.toStringAsFixed(0) : set.weight.toString());
            
            final activeState = ref.watch(workoutSessionControllerProvider).value;
            final isPR = set.id != null && set.id == activeState?.lastPRSetId;
            final prevSet = activeState?.previousSetsByExercise[widget.exerciseId]?.elementAtOrNull(idx);

            return _AnimatedSetRow(
              child: _buildSetRow(theme, idx.toString(), weightText, set.reps.toString(), isCompleted: true, showPRBadge: isPR, set: set, previousSet: prevSet, phase: phase, rangeBottom: rangeBottom, rangeTop: rangeTop),
            );
          }),

          // Active Input Row
          if (widget.completedSets.length >= targetSets && !_showExtraSetInput)
            _buildAllSetsComplete(theme)
          else
            _buildActiveRow(
              theme, 
              currentSetNum.toString(), 
              ref.watch(workoutSessionControllerProvider).value?.previousSetsByExercise[widget.exerciseId]?.elementAtOrNull(widget.completedSets.length),
            ),
          const SizedBox(height: 8),
          _buildComparisonPanel(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildComparisonPanel() {
    final activeState = ref.watch(workoutSessionControllerProvider).value;
    if (activeState == null || activeState.sessionId == null || activeState.routineId == null) {
      return const SizedBox.shrink();
    }
    return ComparisonPanel(
      routineId: activeState.routineId!,
      currentSessionId: activeState.sessionId!,
      exerciseId: widget.exerciseId,
      currentSets: widget.completedSets,
      weightUnit: widget.weightUnit,
    );
  }



  Widget _buildAllSetsComplete(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.greenDim,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: AppTheme.green),
                const SizedBox(width: 8),
                Text(
                  'All sets complete',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _showExtraSetInput = true;
              });
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.colorScheme.outline, width: 1.5, strokeAlign: BorderSide.strokeAlignInside),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Add extra set', style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt2)),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(
    ThemeData theme, 
    String setNum, 
    String weight, 
    String reps, 
    {
      bool isCompleted = false, 
      bool showPRBadge = false, 
      WorkoutSet? set, 
      WorkoutSet? previousSet,
      TrainingPhase phase = TrainingPhase.none,
      int? rangeBottom,
      int? rangeTop,
    }
  ) {
    final isWarmup = set?.isWarmup ?? false;

    Color repsColor = isCompleted ? AppTheme.txt2 : theme.colorScheme.onSurface;
    Widget? feedbackWidget;
    bool isWarning = false;

    if (isCompleted && !isWarmup && rangeBottom != null && rangeTop != null) {
      final actualReps = int.tryParse(reps) ?? 0;
      final shortfall = rangeBottom - actualReps;
      
      int threshold;
      switch (phase) {
        case TrainingPhase.cutting: threshold = 3; break;
        case TrainingPhase.maintaining: threshold = 2; break;
        case TrainingPhase.gaining: threshold = 1; break;
        case TrainingPhase.none: threshold = 2; break;
      }
      
      if (actualReps >= rangeTop) {
        repsColor = AppTheme.green;
        feedbackWidget = const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Icon(Icons.check, color: AppTheme.green, size: 14),
        );
      } else if (shortfall >= threshold) {
        repsColor = AppTheme.coral;
        isWarning = true;
        feedbackWidget = Padding(
          padding: const EdgeInsets.only(left: 48, top: 4),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppTheme.coral, size: 14),
              const SizedBox(width: 4),
              Text('Below target', style: AppTheme.monoSmall(color: AppTheme.coral).copyWith(fontSize: 12)),
              if (previousSet != null) ...[
                Text('  ·  ', style: AppTheme.monoSmall(color: AppTheme.txt3)),
                Text(
                  'Prev: ${_formatWeight(previousSet.toJson())} × ${previousSet.reps}${previousSet.isWarmup ? ' (W)' : ''}',
                  style: AppTheme.monoSmall(color: AppTheme.txt3).copyWith(fontSize: 12),
                ),
              ],
            ],
          ),
        );
      }
    }

    return Opacity(
      opacity: isWarmup ? 0.6 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: isCompleted && set != null ? () => _editSet(set) : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: set != null && set.id != null ? () {
                        ref.read(workoutSessionControllerProvider.notifier).toggleWarmup(set.id!);
                      } : null,
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isWarmup ? AppTheme.amber : AppTheme.bg1,
                              borderRadius: BorderRadius.circular(8),
                              border: isWarmup ? null : Border.all(color: AppTheme.bg3),
                            ),
                            child: Center(
                              child: Text(
                                isWarmup ? 'W' : setNum,
                                style: AppTheme.monoLarge(color: isWarmup ? AppTheme.bg0 : AppTheme.txt1).copyWith(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('REPS', style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.txt3, fontSize: 10, letterSpacing: 0.5), textAlign: TextAlign.center),
                          const SizedBox(height: 4),
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  reps,
                                  style: AppTheme.monoLarge(color: repsColor).copyWith(
                                    fontSize: 18,
                                    fontStyle: isWarmup ? FontStyle.italic : null,
                                    fontWeight: (repsColor == AppTheme.green || repsColor == AppTheme.coral) ? FontWeight.bold : null,
                                  ),
                                ),
                                if (feedbackWidget != null && repsColor == AppTheme.green)
                                  feedbackWidget,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('WEIGHT (${widget.weightUnit})'.toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.txt3, fontSize: 10, letterSpacing: 0.5), textAlign: TextAlign.center),
                          const SizedBox(height: 4),
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              weight,
                              style: AppTheme.monoLarge(color: isCompleted ? AppTheme.txt2 : theme.colorScheme.onSurface).copyWith(
                                fontSize: 18,
                                fontStyle: isWarmup ? FontStyle.italic : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showPRBadge) ...[
                      const SizedBox(width: 8),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: _AnimatedPRBadge(size: PRBadgeSize.sm),
                      ),
                    ],
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: isCompleted
                          ? Container(
                              decoration: BoxDecoration(
                                color: AppTheme.greenDim,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.4, end: 1.0),
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.elasticOut,
                                builder: (context, scale, child) => Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.diagonal3Values(scale, scale, 1.0)
                                    ..rotateZ((1.0 - scale) * -0.1745), // slight rotation
                                  child: child,
                                ),
                                child: const Icon(Icons.check, color: AppTheme.green),
                              ),
                            )
                          : IconButton.filled(
                              onPressed: _logSet,
                              icon: const Icon(Icons.check),
                              style: IconButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            if (isWarning)
              feedbackWidget!
            else if (previousSet != null)
              Padding(
                padding: const EdgeInsets.only(left: 48, top: 4),
                child: Text(
                  'Prev: ${_formatWeight(previousSet.toJson())} × ${previousSet.reps}${previousSet.isWarmup ? ' (W)' : ''}',
                  style: AppTheme.monoSmall(color: AppTheme.txt3).copyWith(fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveRow(ThemeData theme, String setNum, WorkoutSet? previousSet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_showHint)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 4),
              child: GestureDetector(
                onTap: () => setState(() => _showHint = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.bg2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.amber.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lightbulb_outline, color: AppTheme.amber, size: 16),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Tip: tap the set number to mark as warm-up.',
                          style: AppTheme.monoSmall(color: AppTheme.txt1).copyWith(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.close, color: AppTheme.txt3, size: 14),
                    ],
                  ),
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _isWarmupActive = !_isWarmupActive;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _isWarmupActive ? AppTheme.amber : AppTheme.bg1,
                        borderRadius: BorderRadius.circular(8),
                        border: _isWarmupActive ? null : Border.all(color: AppTheme.bg3),
                      ),
                      child: Center(
                        child: Text(
                          _isWarmupActive ? 'W' : setNum,
                          style: AppTheme.monoLarge(color: _isWarmupActive ? AppTheme.bg0 : AppTheme.txt1).copyWith(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildNumInput('REPS', _repsController, _repsFocus, _weightFocus, theme)),
              const SizedBox(width: 8),
              Expanded(child: _buildNumInput('WEIGHT (${widget.weightUnit})'.toUpperCase(), _weightController, _weightFocus, null, theme)),
              const SizedBox(width: 8),
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton.filled(
                  onPressed: _logSet,
                  icon: const Icon(Icons.check),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          if (previousSet != null)
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 4),
              child: Text(
                'Prev: ${_formatWeight(previousSet.toJson())} × ${previousSet.reps}${previousSet.isWarmup ? ' (W)' : ''}',
                style: AppTheme.monoSmall(color: AppTheme.txt3).copyWith(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNumInput(String label, TextEditingController controller, FocusNode focusNode, FocusNode? nextFocus, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.txt3, fontSize: 10, letterSpacing: 0.5), textAlign: TextAlign.center),
        const SizedBox(height: 4),
        SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: widget.weightUnit == 'custom' && controller == _weightController
                ? TextInputType.text
                : const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: AppTheme.monoLarge(color: theme.colorScheme.onSurface).copyWith(fontSize: 18),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
            textInputAction: nextFocus != null ? TextInputAction.next : TextInputAction.done,
            onSubmitted: (_) {
              if (nextFocus != null) {
                nextFocus.requestFocus();
              } else {
                _logSet();
              }
            },
          ),
        ),
      ],
    );
  }
}

class _EditSetDialog extends StatefulWidget {
  final WorkoutSet set;
  final String weightUnit;
  final Function(double?, int, String?) onSave;
  final VoidCallback onDelete;

  const _EditSetDialog({
    required this.set,
    required this.weightUnit,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<_EditSetDialog> createState() => _EditSetDialogState();
}

class _EditSetDialogState extends State<_EditSetDialog> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.weightUnit == 'custom' 
          ? widget.set.customWeight 
          : (widget.weightUnit == 'plates' ? widget.set.weight.toStringAsFixed(0) : widget.set.weight.toString()),
    );
    _repsController = TextEditingController(text: widget.set.reps.toString());
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _save() {
    double? weight;
    String? customWeight;
    if (widget.weightUnit == 'custom') {
      customWeight = _weightController.text;
    } else {
      weight = double.tryParse(_weightController.text);
    }
    final reps = int.tryParse(_repsController.text) ?? widget.set.reps;
    
    widget.onSave(weight, reps, customWeight);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: AppTheme.bg2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit Set',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.txt1),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
              Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reps', style: theme.textTheme.labelMedium?.copyWith(color: AppTheme.txt2)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _repsController,
                        keyboardType: TextInputType.number,
                        style: AppTheme.monoLarge(color: AppTheme.txt1).copyWith(fontSize: 18),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.bg1,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weight (${widget.weightUnit})', style: theme.textTheme.labelMedium?.copyWith(color: AppTheme.txt2)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _weightController,
                        keyboardType: widget.weightUnit == 'custom' ? TextInputType.text : const TextInputType.numberWithOptions(decimal: true),
                        style: AppTheme.monoLarge(color: AppTheme.txt1).copyWith(fontSize: 18),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.bg1,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onDelete();
                      if (mounted) Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.coral,
                      side: const BorderSide(color: AppTheme.coral),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.amber,
                      foregroundColor: AppTheme.bg0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
