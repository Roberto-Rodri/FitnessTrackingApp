import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/routing/router.dart';
import '../controllers/workout_providers.dart';
import '../../../profile/presentation/controllers/profile_providers.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../domain/entities/workout_summary_detail.dart';

class WorkoutSummaryScreen extends ConsumerWidget {
  final int sessionId;

  const WorkoutSummaryScreen({super.key, required this.sessionId});

  String _getPhaseMessage(TrainingPhase phase) {
    switch (phase) {
      case TrainingPhase.gaining:
        return 'Massive volume for your bulk!';
      case TrainingPhase.cutting:
        return 'Staying sharp on your cut!';
      case TrainingPhase.maintaining:
      case TrainingPhase.none:
        return 'Great workout!';
    }
  }

  String _formatDuration(int startTimestamp, int? endTimestamp) {
    if (endTimestamp == null) return '--:--';
    final d = Duration(milliseconds: endTimestamp - startTimestamp);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summaryAsync = ref.watch(workoutSummaryProvider(sessionId));
    final profileAsync = ref.watch(userProfileControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg0,
      body: SafeArea(
        child: summaryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(child: Text('Error: $err')),
          data: (summary) {
            final durationStr = _formatDuration(summary.session.startTimestamp, summary.session.endTimestamp);
            final phase = profileAsync.value?.phase ?? TrainingPhase.none;
            final message = _getPhaseMessage(phase);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          size: 80,
                          color: AppTheme.amber,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Workout Complete',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.txt1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme.amber,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Stats Grid
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Duration',
                                value: durationStr,
                                icon: Icons.timer,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _StatCard(
                                title: 'Volume',
                                value: '${summary.totalVolume.toStringAsFixed(0)} kg',
                                icon: Icons.fitness_center,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Sets',
                                value: summary.totalSets.toString(),
                                icon: Icons.format_list_numbered,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _StatCard(
                                title: 'PRs Broken',
                                value: summary.totalPRs.toString(),
                                icon: Icons.stars,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        Text(
                          'EXERCISE BREAKDOWN',
                          style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.txt2, letterSpacing: 0.06),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Exercise Breakdown List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final comp = summary.exerciseComparisons[index];
                        return _ExerciseComparisonCard(comparison: comp, phase: phase);
                      },
                      childCount: summary.exerciseComparisons.length,
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Share Button
                        OutlinedButton.icon(
                          icon: const Icon(Icons.share, color: AppTheme.amber),
                          label: const Text('Share to Instagram', style: TextStyle(color: AppTheme.amber, fontSize: 16, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.amber),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            context.pushNamed(RouteNames.workoutShare, pathParameters: {'sessionId': summary.session.id!.toString()});
                          },
                        ),
                        const SizedBox(height: 16),

                        // Done Button
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.amber,
                            foregroundColor: AppTheme.bg0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            context.goNamed(RouteNames.home);
                          },
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ExerciseComparisonCard extends StatelessWidget {
  final ExerciseComparison comparison;
  final TrainingPhase phase;

  const _ExerciseComparisonCard({required this.comparison, required this.phase});

  Color _getComparisonColor(bool increased) {
    if (increased) {
      return AppTheme.green;
    } else {
      // During a cut, losing volume is less penalized (amber). During a bulk, losing volume is bad (coral).
      if (phase == TrainingPhase.cutting) {
        return AppTheme.amber;
      }
      return AppTheme.coral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final increased = comparison.previousVolume != null && comparison.currentVolume > comparison.previousVolume!;
    final decreased = comparison.previousVolume != null && comparison.currentVolume < comparison.previousVolume!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bg1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  comparison.exercise.name,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.txt1),
                ),
              ),
              if (comparison.hasPR)
                const Icon(Icons.star, color: AppTheme.amber, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Volume', style: AppTheme.monoSmall(color: AppTheme.txt2)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${comparison.currentVolume.toStringAsFixed(0)} ${comparison.exercise.weightUnit}',
                        style: AppTheme.monoMedium(color: AppTheme.txt1),
                      ),
                      if (comparison.previousVolume != null && (increased || decreased)) ...[
                        const SizedBox(width: 8),
                        Icon(
                          increased ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 14,
                          color: _getComparisonColor(increased),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Sets', style: AppTheme.monoSmall(color: AppTheme.txt2)),
                  const SizedBox(height: 4),
                  Text(
                    '${comparison.currentSets}',
                    style: AppTheme.monoMedium(color: AppTheme.txt1),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bg1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.txt2),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTheme.monoSmall(color: AppTheme.txt2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTheme.monoLarge(color: AppTheme.txt1).copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
