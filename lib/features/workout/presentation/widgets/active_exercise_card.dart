import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/workout_set.dart';
import 'exercise_swap_sheet.dart';
import 'quick_swap_sheet.dart';
import '../../../../core/theme/theme.dart';
import 'body_part_tag.dart';
import '../../domain/entities/exercise.dart';
import '../controllers/workout_providers.dart';
import 'pr_badge.dart';

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
      await ref.read(workoutSessionNotifierProvider.notifier).logNewSet(newSet);
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
    final targetSets = int.tryParse(widget.targetSetsAndReps.split('×').first.trim()) ?? 3;
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
                            if (widget.bestSet != null)
                              Text.rich(TextSpan(children: [
                                TextSpan(text: 'Best: ', style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.txt2, fontSize: 12)),
                                TextSpan(
                                  text: '${_formatWeight(widget.bestSet!)} × ${widget.bestSet!['reps']}', 
                                  style: AppTheme.monoSmall(color: AppTheme.amber).copyWith(fontSize: 12),
                                ),
                              ])),
                            if (widget.bestSet != null && latestSet != null)
                              Text('  ·  ', style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.txt3)),
                            if (latestSet != null)
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
                InkWell(
                  onTap: () async {
                    void showFullSwapSheet() {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => ExerciseSwapSheet(
                          currentExerciseId: widget.exerciseId,
                          onExerciseSelected: (newExercise) {
                            ref.read(workoutSessionNotifierProvider.notifier)
                                .swapExercise(widget.exerciseId, newExercise);
                          },
                        ),
                      );
                    }

                    if (widget.alternatives != null && widget.alternatives!.isNotEmpty) {
                      final result = await showModalBottomSheet<dynamic>(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => QuickSwapSheet(
                          alternatives: widget.alternatives!,
                        ),
                      );

                      if (result == 'SHOW_MORE') {
                        if (mounted) showFullSwapSheet();
                      } else if (result is Exercise) {
                        ref.read(workoutSessionNotifierProvider.notifier)
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
                )
              ],
            ),
          ),
          
          // Sets Table Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(width: 32, child: Text('Set', style: _colHeaderStyle(theme))),
                const SizedBox(width: 16),
                Expanded(child: Text(widget.weightUnit == 'custom' ? 'Weight' : widget.weightUnit, style: _colHeaderStyle(theme))),
                const SizedBox(width: 8),
                Expanded(child: Text('Reps', style: _colHeaderStyle(theme))),
                const SizedBox(width: 8),
                const SizedBox(width: 44), 
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Completed Sets
          ...widget.completedSets.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final set = entry.value;
            final weightText = widget.weightUnit == 'custom'
                ? (set.customWeight ?? '')
                : (widget.weightUnit == 'plates' ? set.weight.toStringAsFixed(0) : set.weight.toString());
            
            final activeState = ref.watch(workoutSessionNotifierProvider).valueOrNull;
            final isPR = set.id != null && set.id == activeState?.lastPRSetId;
            final prevSet = activeState?.previousSetsByExercise[widget.exerciseId]?.elementAtOrNull(idx);

            return _AnimatedSetRow(
              child: _buildSetRow(theme, idx.toString(), weightText, set.reps.toString(), isCompleted: true, showPRBadge: isPR, set: set, previousSet: prevSet),
            );
          }),

          // Active Input Row
          if (widget.completedSets.length >= targetSets && !_showExtraSetInput)
            _buildAllSetsComplete(theme)
          else
            _buildActiveRow(
              theme, 
              currentSetNum.toString(), 
              ref.watch(workoutSessionNotifierProvider).valueOrNull?.previousSetsByExercise[widget.exerciseId]?.elementAtOrNull(widget.completedSets.length),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  TextStyle _colHeaderStyle(ThemeData theme) {
    return theme.textTheme.labelSmall!.copyWith(color: AppTheme.txt2, letterSpacing: 0.5);
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

  Widget _buildSetRow(ThemeData theme, String setNum, String weight, String reps, {bool isCompleted = false, bool showPRBadge = false, WorkoutSet? set, WorkoutSet? previousSet}) {
    final isWarmup = set?.isWarmup ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
          InkWell(
            onTap: set != null && set.id != null ? () {
              ref.read(workoutSessionNotifierProvider.notifier).toggleWarmup(set.id!);
            } : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isWarmup ? AppTheme.amber : AppTheme.bg2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  isWarmup ? 'W' : setNum,
                  style: AppTheme.monoLarge(color: isWarmup ? AppTheme.bg0 : AppTheme.txt1).copyWith(fontSize: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                weight,
                style: AppTheme.monoLarge(color: isCompleted ? AppTheme.txt2 : theme.colorScheme.onSurface).copyWith(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                reps,
                style: AppTheme.monoLarge(color: isCompleted ? AppTheme.txt2 : theme.colorScheme.onSurface).copyWith(fontSize: 18),
              ),
            ),
          ),
          if (showPRBadge) ...[
            const SizedBox(width: 8),
            const _AnimatedPRBadge(size: PRBadgeSize.sm),
          ],
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            height: 44,
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

  Widget _buildActiveRow(ThemeData theme, String setNum, WorkoutSet? previousSet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
          InkWell(
            onTap: () {
              setState(() {
                _isWarmupActive = !_isWarmupActive;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _isWarmupActive ? AppTheme.amber : AppTheme.bg2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _isWarmupActive ? 'W' : setNum,
                  style: AppTheme.monoLarge(color: _isWarmupActive ? AppTheme.bg0 : AppTheme.txt1).copyWith(fontSize: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: _buildNumInput(_weightController, _weightFocus, _repsFocus, theme)),
          const SizedBox(width: 8),
          Expanded(child: _buildNumInput(_repsController, _repsFocus, null, theme)),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            height: 44,
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

  Widget _buildNumInput(TextEditingController controller, FocusNode focusNode, FocusNode? nextFocus, ThemeData theme) {
    return SizedBox(
      height: 44,
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
    );
  }
}
