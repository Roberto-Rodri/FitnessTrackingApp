import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/workout_providers.dart';
import '../widgets/active_exercise_card.dart';
import '../widgets/workout_status_bar.dart';
import '../widgets/rest_timer_panel.dart';
import '../../../../core/theme/theme.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  Future<void> _finishWorkout() async {
    final sessionState = ref.read(workoutSessionNotifierProvider);
    final setsCount = sessionState.value?.sets.length ?? 0;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          tween: Tween(begin: 0.8, end: 1.0),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Dialog(
            backgroundColor: theme.colorScheme.surfaceContainerHigh,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 32.0, bottom: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Finish Workout?',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "You've crushed $setsCount sets today.",
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Finish & Save', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
      },
    );

    if (confirm == true) {
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 100), () {
        HapticFeedback.lightImpact();
      });
      await ref.read(workoutSessionNotifierProvider.notifier).endSession();
      if (mounted) {
        ref.read(showConfettiProvider.notifier).state = true;
        Future.delayed(const Duration(seconds: 4), () {
          ref.read(showConfettiProvider.notifier).state = false;
        });
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(workoutSessionNotifierProvider, (previous, next) {
      if (previous != null && next.hasValue) {
        final prevCount = previous.value?.loggedSetCount ?? 0;
        final nextCount = next.value?.loggedSetCount ?? 0;
        if (nextCount > prevCount && next.value?.lastLoggedRestSeconds != null) {
          ref.read(restTimerDurationProvider.notifier).state = next.value!.lastLoggedRestSeconds!;
        }
      }
    });

    final sessionState = ref.watch(workoutSessionNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: sessionState.when(
          data: (activeState) {
            if (activeState.sessionId == null || activeState.routineId == null) {
              return const Center(child: Text('No active session. Go back.'));
            }

            final exercises = activeState.activeExercises;
            final useRoutineLatest = ref.watch(useRoutineLatestProvider);

            return Column(
              children: [
                // Custom Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => context.go('/'),
                      ),
                      Text(
                        'WORKOUT',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Text(
                        'REFERENCE DATA',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: AppTheme.txt3,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => ref.read(useRoutineLatestProvider.notifier).state = false,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: !useRoutineLatest ? AppTheme.amber : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'All',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: !useRoutineLatest ? AppTheme.amber : AppTheme.txt2,
                              fontWeight: !useRoutineLatest ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => ref.read(useRoutineLatestProvider.notifier).state = true,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: useRoutineLatest ? AppTheme.amber : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'Routine',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: useRoutineLatest ? AppTheme.amber : AppTheme.txt2,
                              fontWeight: useRoutineLatest ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      ListView.builder(
                        itemCount: exercises.length,
                        padding: const EdgeInsets.only(bottom: 100), // padding for timer
                        itemBuilder: (context, index) {
                          final ex = exercises[index];
                          return ActiveExerciseCard(
                            exerciseId: ex.exerciseId,
                            exerciseName: ex.exerciseName,
                            targetSetsAndReps: '${ex.targetSets} × ${ex.targetReps}',
                            completedSets: activeState.sets.where((s) => s.exerciseId == ex.exerciseId).toList(),
                            weightUnit: ex.weightUnit,
                            bodyPart: ex.bodyPart,
                            bestSet: activeState.bestSets[ex.exerciseId],
                            latestSetGlobal: activeState.latestSetsGlobal[ex.exerciseId],
                            latestSetRoutine: activeState.latestSetsRoutine[ex.exerciseId],
                            useRoutineLatest: useRoutineLatest,
                            alternatives: activeState.alternatives[ex.exerciseId],
                          );
                        },
                      ),
                      const RestTimerPanel(),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
      bottomNavigationBar: WorkoutStatusBar(
        onFinish: _finishWorkout,
        startTimestamp: sessionState.value?.startTimestamp,
      ),
    );
  }
}
