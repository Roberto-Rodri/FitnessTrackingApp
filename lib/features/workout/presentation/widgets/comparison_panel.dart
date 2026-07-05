import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../controllers/workout_providers.dart';
import '../../../profile/presentation/controllers/profile_providers.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../domain/entities/workout_set.dart';

class ComparisonPanel extends ConsumerStatefulWidget {
  final int routineId;
  final int currentSessionId;
  final int exerciseId;
  final List<WorkoutSet> currentSets;
  final String weightUnit;

  const ComparisonPanel({
    super.key,
    required this.routineId,
    required this.currentSessionId,
    required this.exerciseId,
    required this.currentSets,
    required this.weightUnit,
  });

  @override
  ConsumerState<ComparisonPanel> createState() => _ComparisonPanelState();
}

class _ComparisonPanelState extends ConsumerState<ComparisonPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previousSessionAsync = ref.watch(previousSessionProvider(widget.routineId, widget.currentSessionId));

    return previousSessionAsync.when(
      data: (summary) {
        if (summary == null) return const SizedBox.shrink();

        final previousSetsAll = ref.watch(workoutSessionControllerProvider).value?.previousSetsByExercise[widget.exerciseId] ?? [];
        final previousSets = previousSetsAll.where((s) => s.sessionId == summary.session.id && !s.isWarmup).toList();
        
        if (previousSets.isEmpty) return const SizedBox.shrink();

        final currentWorkSets = widget.currentSets.where((s) => !s.isWarmup).toList();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.bg3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.compare_arrows, color: AppTheme.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Set-by-Set Comparison',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: AppTheme.txt2),
                    ],
                  ),
                ),
              ),
              if (_expanded)
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                  child: Column(
                    children: List.generate(
                      previousSets.length,
                      (index) {
                        final prevSet = previousSets[index];
                        final currSet = index < currentWorkSets.length ? currentWorkSets[index] : null;
                        return _CompareRow(
                          prevSet: prevSet,
                          currSet: currSet,
                          setNum: index + 1,
                          weightUnit: widget.weightUnit,
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _CompareRow extends ConsumerWidget {
  final WorkoutSet prevSet;
  final WorkoutSet? currSet;
  final int setNum;
  final String weightUnit;

  const _CompareRow({
    required this.prevSet,
    this.currSet,
    required this.setNum,
    required this.weightUnit,
  });

  String _formatWeight(WorkoutSet set) {
    if (weightUnit == 'custom') return set.customWeight ?? '';
    if (weightUnit == 'plates') return set.weight.toStringAsFixed(0);
    final w = set.weight;
    return w.toStringAsFixed(w.truncateToDouble() == w ? 0 : 1);
  }

  Color _getArrowColor(double diff, TrainingPhase phase) {
    if (diff == 0) return AppTheme.txt1;
    if (diff > 0) return AppTheme.green;
    
    if (phase == TrainingPhase.gaining) return AppTheme.coral;
    return AppTheme.txt1;
  }

  IconData _getArrowIcon(double diff) {
    if (diff == 0) return Icons.arrow_forward;
    if (diff > 0) return Icons.arrow_upward;
    return Icons.arrow_downward;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileControllerProvider);
    final phase = profileAsync.value?.phase ?? TrainingPhase.none;

    final prevStr = '${_formatWeight(prevSet)} × ${prevSet.reps}';
    final currStr = currSet != null ? '${_formatWeight(currSet!)} × ${currSet!.reps}' : '--';

    double diff = 0;
    if (currSet != null && weightUnit != 'custom') {
      diff = currSet!.weight - prevSet.weight;
      if (diff == 0) {
        diff = (currSet!.reps - prevSet.reps).toDouble();
      }
    }

    final arrowColor = _getArrowColor(diff, phase);
    final arrowIcon = _getArrowIcon(diff);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$setNum',
              style: AppTheme.monoMedium(color: AppTheme.txt2),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              prevStr,
              style: AppTheme.monoMedium(color: AppTheme.txt2),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          if (currSet != null)
            Icon(arrowIcon, color: arrowColor, size: 16)
          else
            const Icon(Icons.arrow_forward, color: AppTheme.txt3, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              currStr,
              style: AppTheme.monoMedium(color: currSet != null ? AppTheme.txt1 : AppTheme.txt3),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
