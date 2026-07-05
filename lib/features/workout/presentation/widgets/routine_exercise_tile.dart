import 'package:flutter/material.dart';
import '../../domain/entities/routine_exercise_detail.dart';
import '../../../../core/theme/theme.dart';
import 'body_part_tag.dart';

class RoutineExerciseTile extends StatelessWidget {
  final RoutineExerciseDetail exercise;
  final int index;
  final VoidCallback onEditTargets;
  final VoidCallback onDismissed;

  const RoutineExerciseTile({
    super.key,
    required this.exercise,
    required this.index,
    required this.onEditTargets,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey('dismiss_${exercise.exerciseId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(Icons.delete, color: theme.colorScheme.onErrorContainer),
      ),
      onDismissed: (_) => onDismissed(),
      child: Container(
        key: ValueKey(exercise.exerciseId),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Drag Handle area
              Container(
                width: 48,
                alignment: Alignment.center,
                child: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_indicator, color: AppTheme.txt2),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        exercise.exerciseName,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      BodyPartTag(bodyPart: exercise.bodyPart),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: onEditTargets,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${exercise.targetSets} × ${exercise.targetReps}',
                        style: AppTheme.monoLarge(color: theme.colorScheme.onSurface).copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
