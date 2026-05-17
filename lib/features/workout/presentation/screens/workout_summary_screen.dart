import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/routing/router.dart';
import '../controllers/workout_providers.dart';
import '../../../profile/presentation/controllers/profile_providers.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../domain/entities/workout_session_summary.dart';

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
    final completedSessionsAsync = ref.watch(completedSessionsProvider);
    final prCountAsync = ref.watch(sessionPRCountProvider(sessionId));
    final profileAsync = ref.watch(userProfileControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg0,
      body: SafeArea(
        child: completedSessionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(child: Text('Error: $err')),
          data: (sessions) {
            final summary = sessions.cast<WorkoutSessionSummary?>().firstWhere(
              (s) => s?.session.id == sessionId,
              orElse: () => null,
            );

            if (summary == null) {
              return const Center(child: Text('Session not found.'));
            }

            final durationStr = _formatDuration(summary.session.startTimestamp, summary.session.endTimestamp);
            final phase = profileAsync.valueOrNull?.phase ?? TrainingPhase.none;
            final message = _getPhaseMessage(phase);
            final prCount = prCountAsync.valueOrNull ?? 0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Celebration Icon
                  const Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: AppTheme.amber,
                  ),
                  const SizedBox(height: 24),
                  // Header
                  Text(
                    'Workout Complete',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.txt1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Phase Message
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.amber,
                    ),
                  ),
                  const SizedBox(height: 48),

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
                          title: 'PRs Broken',
                          value: prCount.toString(),
                          icon: Icons.stars,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

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
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bg1,
        borderRadius: BorderRadius.circular(20),
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
