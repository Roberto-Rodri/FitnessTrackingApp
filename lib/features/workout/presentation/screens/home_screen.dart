import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/router.dart';
import '../controllers/workout_providers.dart';
import '../../../../core/theme/theme.dart';
import '../../../profile/presentation/controllers/profile_providers.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/widgets/name_prompt_dialog.dart';
import '../widgets/session_history_card.dart';
import '../widgets/skeleton_loading.dart';
import '../widgets/error_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/body_weight_card.dart';
import '../../../program/presentation/controllers/program_providers.dart';
import '../../../program/presentation/widgets/next_workout_card.dart';
import '../../../program/presentation/widgets/cycle_progress_strip.dart';
import '../../../program/domain/entities/program_detail.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNamePrompt();
    });
  }

  Future<void> _checkNamePrompt() async {
    final profile = await ref.read(userProfileControllerProvider.future);
    if (profile.name == null && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const NamePromptDialog(),
      );
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  String _getFormattedDate() {
    return DateFormat('EEEE, MMMM d').format(DateTime.now());
  }

  void _showRoutinePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final routinesAsync = ref.watch(routineListProvider);
            return routinesAsync.when(
              data: (routines) {
                if (routines.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text('No routines available. Create one first!'),
                    ),
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: routines.length,
                      itemBuilder: (context, index) {
                        final routine = routines[index];
                        return ListTile(
                          title: Text(routine.name),
                          subtitle: Text('${routine.exerciseCount} exercises'),
                          onTap: () async {
                            Navigator.of(context).pop();
                            await ref.read(workoutSessionControllerProvider.notifier).startSession(routine.id, routine.name);
                            HapticFeedback.mediumImpact();
                            if (!context.mounted) return;
                            context.pushNamed(RouteNames.activeWorkout);
                          },
                        );
                      },
                    ),
                  ],
                );
              },
              loading: () => const Padding(padding: EdgeInsets.all(32.0), child: Center(child: CircularProgressIndicator())),
              error: (e, _) => ErrorCard(
                message: e.toString(),
                onRetry: () => ref.invalidate(routineListProvider),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProfileAsync = ref.watch(userProfileControllerProvider);
    final weeklyStatsAsync = ref.watch(weeklyStatsProvider);
    final chartAsync = ref.watch(weeklyVolumeChartProvider);
    final recentAsync = ref.watch(recentSessionsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER AREA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getFormattedDate(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.txt2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_getGreeting()}, ${userProfileAsync.value?.name ?? 'Athlete'}.',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 25,
                          letterSpacing: -0.4,
                        ),
                      ),
                      if (userProfileAsync.value?.phase != null && userProfileAsync.value!.phase != TrainingPhase.none) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            userProfileAsync.value!.phase.name.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.analytics_outlined),
                        color: theme.colorScheme.primary,
                        onPressed: () => context.pushNamed(RouteNames.progressReport),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          context.pushNamed(RouteNames.profileSettings);
                        },
                        child: Container(
                          width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHigh,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (userProfileAsync.value?.phase != null && userProfileAsync.value!.phase != TrainingPhase.none)
                              ? theme.colorScheme.primary.withValues(alpha: 0.4)
                              : AppTheme.bg3,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          (userProfileAsync.value?.name?.isNotEmpty ?? false) 
                              ? userProfileAsync.value!.name![0].toUpperCase() 
                              : 'A',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ), // closes Center
                    ), // closes Container
                  ), // closes GestureDetector
                ],
              ),
            ],
          ),
            const SizedBox(height: 24),
              
              _buildProgramOrFallbackDashboard(context, ref),
              
              const SizedBox(height: 32),




              // WEEKLY STATS
              Text(
                'THIS WEEK',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.txt2,
                  letterSpacing: 0.06,
                ),
              ),
              const SizedBox(height: 8),
              weeklyStatsAsync.when(
                data: (stats) => Row(
                  children: [
                    Expanded(child: _buildStatPill('SESSIONS', stats.sessionsCount.toString(), '', AppTheme.amber)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatPill('VOLUME', stats.totalVolume.toStringAsFixed(0), 'kg', theme.colorScheme.onSurface)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatPill('STREAK', stats.streak.toString(), 'd', theme.colorScheme.tertiary)),
                  ],
                ),
                loading: () => const Row(
                  children: [
                    Expanded(child: SkeletonStatPill()),
                    SizedBox(width: 12),
                    Expanded(child: SkeletonStatPill()),
                    SizedBox(width: 12),
                    Expanded(child: SkeletonStatPill()),
                  ],
                ),
                error: (e, _) => ErrorCard(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(weeklyStatsProvider),
                ),
              ),
              const SizedBox(height: 24),

              // VOLUME CHART
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'VOLUME / DAY',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.txt2,
                            letterSpacing: 0.06,
                          ),
                        ),
                        Text(
                          'kg',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.amber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    chartAsync.when(
                      data: (chartData) => _buildChart(chartData),
                      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                      error: (e, _) => ErrorCard(
                        message: e.toString(),
                        onRetry: () => ref.invalidate(weeklyVolumeChartProvider),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // BODY WEIGHT
              const BodyWeightCard(),
              const SizedBox(height: 32),

              // RECENT WORKOUTS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RECENT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.txt2,
                      letterSpacing: 0.06,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to History tab? Just switch branch.
                      // Shell handles it, but maybe no direct link from here. Just leave as is.
                    },
                    child: Text(
                      'See all',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.amber,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              recentAsync.when(
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: EmptyState(
                        icon: Icon(Icons.history, color: AppTheme.amber, size: 32),
                        headline: 'No workouts yet',
                        subtitle: 'Your training log is empty. Time to hit the iron!',
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sessions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return SessionHistoryCard(
                        summary: sessions[index],
                        onTap: () => context.pushNamed(RouteNames.sessionDetail, pathParameters: {'sessionId': sessions[index].session.id.toString()}),
                      );
                    },
                  );
                },
                loading: () => Column(
                  children: List.generate(2, (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: SkeletonHistoryCard(),
                  )),
                ),
                error: (e, _) => ErrorCard(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(recentSessionsProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, String value, String unit, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.txt2,
              fontSize: 10,
              letterSpacing: 0.05,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTheme.monoLarge(color: valueColor).copyWith(fontSize: 22),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.txt2,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<double> data) {
    final maxVol = data.fold(0.0, (m, v) => v > m ? v : m);
    final todayIndex = DateTime.now().weekday - 1;
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return SizedBox(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final isToday = index == todayIndex;
          final val = data[index];
          final factor = maxVol > 0 ? (val / maxVol) : 0.0;
          final barHeight = factor * 80;

          Color barColor;
          if (isToday) {
            barColor = AppTheme.amber;
          } else if (val > 0) {
            barColor = Theme.of(context).colorScheme.outline.withValues(alpha: 0.75);
          } else {
            barColor = Theme.of(context).colorScheme.outline.withValues(alpha: 0.40);
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 28,
                height: barHeight > 0 ? barHeight : 4,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                days[index],
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isToday ? AppTheme.amber : AppTheme.txt2,
                  fontSize: 12,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildProgramOrFallbackDashboard(BuildContext context, WidgetRef ref) {
    final activeProgramAsync = ref.watch(activeProgramProvider);
    final currentDayAsync = ref.watch(currentProgramDayProvider);
    final completedDaysAsync = ref.watch(completedProgramDaysProvider);

    if (activeProgramAsync is AsyncLoading || currentDayAsync is AsyncLoading) {
      return const SkeletonRoutineCard(); // Fallback skeleton
    }

    final activeProgram = activeProgramAsync.value;
    final currentDay = currentDayAsync.value;
    final completedDays = completedDaysAsync.value ?? <int>{};


    if (activeProgram != null && currentDay != null) {
      // Show NextWorkoutCard
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NextWorkoutCard(
            programName: activeProgram.program.name,
            currentDay: currentDay.dayIndex + 1,
            totalDays: activeProgram.program.cycleLengthDays,
            routineName: currentDay.routineId != null ? currentDay.label : 'Unassigned Workout',
            bodyParts: currentDay.routineId != null ? ['Push', 'Pull'] : [], // Simplification, would need routine details
            exerciseCount: 0, // Simplification, would need routine details
            onStart: currentDay.routineId != null ? () async {
              await ref.read(workoutSessionControllerProvider.notifier).startSession(
                currentDay.routineId!,
                currentDay.label,
                programId: activeProgram.program.id,
                programDayIndex: currentDay.dayIndex,
                isOverride: false,
              );
              HapticFeedback.mediumImpact();
              if (context.mounted) context.pushNamed(RouteNames.activeWorkout);
            } : null,
            onDifferentDay: () => _showDifferentDaySheet(context, ref, activeProgram, completedDays),
          ),
          const SizedBox(height: 16),
          CycleProgressStrip(
            days: activeProgram.days,
            currentDayIndex: activeProgram.program.currentDayIndex,
            completedDayIndices: completedDays,
          ),
        ],
      );
    } else {
      // Fallback
      return _buildFallbackDashboard(context, ref);
    }
  }

  Widget _buildFallbackDashboard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lastRoutineAsync = ref.watch(lastRoutineProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: _showRoutinePicker,
            icon: const Icon(Icons.play_arrow_rounded, size: 24),
            label: const Text(
              'Start Workout',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 32),
        lastRoutineAsync.when(
          data: (routine) {
            if (routine == null) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QUICK-START',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.txt2,
                    letterSpacing: 0.06,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    await ref.read(workoutSessionControllerProvider.notifier).startSession(routine.id, routine.name);
                    HapticFeedback.mediumImpact();
                    if (!context.mounted) return;
                    context.pushNamed(RouteNames.activeWorkout);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outline),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.outline,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.fitness_center, color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                routine.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${routine.exerciseCount} exercises',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.txt2,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppTheme.txt2),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (e, _) => ErrorCard(
            message: e.toString(),
            onRetry: () => ref.invalidate(lastRoutineProvider),
          ),
        ),
      ],
    );
  }

  void _showDifferentDaySheet(BuildContext context, WidgetRef ref, ProgramDetail programDetail, Set<int> completedDays) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bg1,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.9,
          initialChildSize: 0.6,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 8),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.bg3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Pick a workout day',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.txt0,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: programDetail.days.length,
                    itemBuilder: (context, index) {
                      final day = programDetail.days[index];
                      final isCompleted = completedDays.contains(day.dayIndex);
                      final isCurrent = day.dayIndex == programDetail.program.currentDayIndex;
                      final isRest = day.label.toLowerCase() == 'rest';
                      final isUnassigned = day.routineId == null && !isRest;
                      final canStart = day.routineId != null && !isRest;

                      Widget? trailingWidget;
                      if (isCompleted) {
                        trailingWidget = const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: AppTheme.green, size: 16),
                            SizedBox(width: 4),
                            Text('(completed)', style: TextStyle(color: AppTheme.txt2, fontSize: 13)),
                          ],
                        );
                      } else if (isCurrent) {
                        trailingWidget = const Text('(next up)', style: TextStyle(color: AppTheme.amber, fontSize: 13));
                      } else if (isRest) {
                        trailingWidget = const Text('(rest)', style: TextStyle(color: AppTheme.txt3, fontSize: 13));
                      } else if (isUnassigned) {
                        trailingWidget = const Text('(unassigned)', style: TextStyle(color: AppTheme.txt2, fontStyle: FontStyle.italic, fontSize: 13));
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isRest ? AppTheme.bg2 : (isCurrent ? AppTheme.amber.withValues(alpha: 0.2) : AppTheme.bg2),
                          child: Text(
                            isRest ? 'R' : day.label.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: isRest ? AppTheme.txt3 : (isCurrent ? AppTheme.amber : AppTheme.txt1),
                            ),
                          ),
                        ),
                        title: Text(
                          'Day ${day.dayIndex + 1} · ${day.label}',
                          style: TextStyle(
                            color: isRest ? AppTheme.txt3 : AppTheme.txt0,
                            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        trailing: trailingWidget,
                        onTap: canStart ? () async {
                          Navigator.of(context).pop();
                          await ref.read(workoutSessionControllerProvider.notifier).startSession(
                            day.routineId!,
                            day.label,
                            programId: programDetail.program.id,
                            programDayIndex: day.dayIndex,
                            isOverride: true,
                          );
                          HapticFeedback.mediumImpact();
                          if (context.mounted) context.pushNamed(RouteNames.activeWorkout);
                        } : null,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
