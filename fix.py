import re
import sys

with open('lib/features/workout/presentation/widgets/active_exercise_card.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Find the start of _buildSetRow
match_start = re.search(r'  Widget _buildSetRow\(ThemeData theme, String setNum, String weight, String reps, \{bool isCompleted = false, bool showPRBadge = false, WorkoutSet\? set, WorkoutSet\? previousSet\}\) \{', content)
start_idx = match_start.start()

# Find the start of _buildActiveRow
match_end = re.search(r'  Widget _buildActiveRow\(ThemeData theme, String setNum, WorkoutSet\? previousSet\) \{', content)
end_idx = match_end.start()

# Replacement code
new_code = """  Widget _buildSetRow(ThemeData theme, String setNum, String weight, String reps, {bool isCompleted = false, bool showPRBadge = false, WorkoutSet? set, WorkoutSet? previousSet}) {
    final isWarmup = set?.isWarmup ?? false;

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
                          style: AppTheme.monoLarge(color: isCompleted ? AppTheme.txt2 : theme.colorScheme.onSurface).copyWith(
                            fontSize: 18,
                            fontStyle: isWarmup ? FontStyle.italic : null,
                          ),
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
                          style: AppTheme.monoLarge(color: isCompleted ? AppTheme.txt2 : theme.colorScheme.onSurface).copyWith(
                            fontSize: 18,
                            fontStyle: isWarmup ? FontStyle.italic : null,
                          ),
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
              ),
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
      ),
    );
  }

"""

new_content = content[:start_idx] + new_code + content[end_idx:]

with open('lib/features/workout/presentation/widgets/active_exercise_card.dart', 'w', encoding='utf-8') as f:
    f.write(new_content)
