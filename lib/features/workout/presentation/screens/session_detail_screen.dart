import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/workout_providers.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/workout_set.dart';
import '../../domain/entities/workout_session_summary.dart';
import '../../domain/entities/exercise.dart';
import '../../../../core/theme/theme.dart';
import '../widgets/body_part_tag.dart';
import '../widgets/skeleton_loading.dart';
import '../widgets/error_state.dart';
import '../widgets/empty_state.dart';

class SessionDetailScreen extends ConsumerWidget {
  final int sessionId;

  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(completedSessionsProvider);
    final setsAsync = ref.watch(sessionSetsProvider(sessionId));
    final infoAsync = ref.watch(sessionExerciseInfoProvider(sessionId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: sessionsAsync.when(
        data: (sessions) {
          final summary = sessions.firstWhere(
            (s) => s.session.id == sessionId,
            orElse: () => throw Exception('Session not found'),
          );
          return _buildBody(context, ref, summary, setsAsync, infoAsync, theme);
        },
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 3,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => const SkeletonHistoryCard(),
        ),
        error: (error, stack) => ErrorScreen(
          subtitle: 'Could not load session details.',
          onRetry: () => ref.invalidate(completedSessionsProvider),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, 
    WidgetRef ref,
    WorkoutSessionSummary summary,
    AsyncValue<List<WorkoutSet>> setsAsync,
    AsyncValue<Map<int, Exercise>> infoAsync,
    ThemeData theme,
  ) {
    if (setsAsync.isLoading || infoAsync.isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => const SkeletonHistoryCard(),
      );
    }

    if (setsAsync.hasError) {
      return ErrorScreen(
        subtitle: 'Could not load session details.',
        onRetry: () => ref.invalidate(sessionSetsProvider(summary.session.id!)),
      );
    }

    final sets = setsAsync.value ?? [];
    final info = infoAsync.value ?? {};

    if (sets.isEmpty) {
      return const EmptyState(
        icon: Icon(Icons.history, color: AppTheme.amber, size: 32),
        headline: 'No sets recorded',
        subtitle: 'This session has no recorded sets.',
      );
    }

    final Map<int, List<WorkoutSet>> groupedSets = {};
    for (final s in sets) {
      groupedSets.putIfAbsent(s.exerciseId, () => []).add(s);
    }

    final date = DateTime.fromMillisecondsSinceEpoch(summary.session.startTimestamp);
    final dateString = DateFormat('EEEE, MMM d, yyyy').format(date);
    final durationString = _formatDuration(summary.session.startTimestamp, summary.session.endTimestamp);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            summary.session.routineNameSnapshot,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: () => _confirmDelete(context, ref, summary.session.id!),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                dateString,
                style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt2),
              ),
              const SizedBox(height: 24),
              
              // 2x2 Stats Grid
              Row(
                children: [
                  Expanded(child: _buildStatBox(theme, 'DURATION', durationString, Icons.schedule)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatBox(theme, 'SETS', '${summary.totalSets}', Icons.fitness_center)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatBox(theme, 'VOLUME', '${summary.totalVolume.toStringAsFixed(0)} kg', Icons.bar_chart)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatBox(theme, 'PRs', '0', Icons.emoji_events)), // Placeholder
                ],
              ),
              const SizedBox(height: 32),

              if (summary.session.notes != null && summary.session.notes!.isNotEmpty) ...[
                Text(
                  'SESSION NOTES',
                  style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.txt2, letterSpacing: 0.06),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.bg1,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.bg3),
                  ),
                  child: Text(
                    summary.session.notes!,
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt1, height: 1.4),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Volume Chart
              Text(
                'VOLUME PER EXERCISE',
                style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.txt2, letterSpacing: 0.06),
              ),
              const SizedBox(height: 16),
              _buildVolumeChart(theme, groupedSets, info),
              const SizedBox(height: 32),

              // Exercises List
              Text(
                'EXERCISES',
                style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.txt2, letterSpacing: 0.06),
              ),
              const SizedBox(height: 16),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final exerciseId = groupedSets.keys.elementAt(index);
                final exerciseSets = groupedSets[exerciseId]!;
                final exercise = info[exerciseId];
                return _buildExerciseCard(theme, exercise, exerciseSets, index + 1);
              },
              childCount: groupedSets.length,
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
      ],
    );
  }

  Widget _buildStatBox(ThemeData theme, String label, String value, IconData icon) {
    return Container(
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
            children: [
              Icon(icon, size: 16, color: AppTheme.amber),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.txt2, letterSpacing: 0.06),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTheme.monoLarge(color: theme.colorScheme.onSurface).copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeChart(ThemeData theme, Map<int, List<WorkoutSet>> groupedSets, Map<int, Exercise> info) {
    // Calculate volumes
    final Map<String, double> volumes = {};
    double maxVol = 0;
    
    for (final entry in groupedSets.entries) {
      final ex = info[entry.key];
      if (ex == null) continue;
      
      double vol = 0;
      for (final s in entry.value) {
        if (ex.weightUnit == 'kg' || ex.weightUnit == 'lbs') {
          vol += s.weight * s.reps;
        }
      }
      
      if (vol > 0) {
        volumes[ex.name] = vol;
        if (vol > maxVol) maxVol = vol;
      }
    }

    if (volumes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: const Text('No volume data available for chart.'),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        children: volumes.entries.map((entry) {
          final factor = maxVol > 0 ? entry.value / maxVol : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                    Text('${entry.value.toStringAsFixed(0)} kg', style: AppTheme.monoLarge(color: AppTheme.txt2).copyWith(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: factor,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExerciseCard(ThemeData theme, Exercise? exercise, List<WorkoutSet> sets, int index) {
    final exerciseName = exercise?.name ?? 'Unknown Exercise';
    final weightUnit = exercise?.weightUnit ?? 'kg';
    final bodyPart = exercise?.bodyPart ?? 'Unknown';

    double vol = 0;
    if (weightUnit == 'kg' || weightUnit == 'lbs') {
      for (final s in sets) {
        vol += s.weight * s.reps;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface,
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: AppTheme.monoLarge(color: AppTheme.txt2).copyWith(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exerciseName,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    BodyPartTag(bodyPart: bodyPart),
                  ],
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 32, child: Text('Set', style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.txt2))),
                      const SizedBox(width: 16),
                      Expanded(child: Text(weightUnit == 'custom' ? 'Weight' : weightUnit, style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.txt2))),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Reps', style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.txt2))),
                      const SizedBox(width: 24), // For PR icon placeholder
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...sets.asMap().entries.map((e) {
                    final setNum = e.key + 1;
                    final s = e.value;
                    final weightText = weightUnit == 'custom'
                        ? (s.customWeight ?? '')
                        : (weightUnit == 'plates' ? s.weight.toStringAsFixed(0) : s.weight.toString());
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: s.isWarmup ? AppTheme.amber : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              s.isWarmup ? 'W' : '$setNum',
                              style: AppTheme.monoLarge(color: s.isWarmup ? AppTheme.amber : theme.colorScheme.onSurface).copyWith(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              weightText,
                              style: AppTheme.monoLarge(color: theme.colorScheme.onSurface).copyWith(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.reps.toString(),
                              style: AppTheme.monoLarge(color: theme.colorScheme.onSurface).copyWith(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 24), 
                        ],
                      ),
                    );
                  }),
                  if (vol > 0) ...[
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Total Volume: ${vol.toStringAsFixed(0)} $weightUnit',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int start, int? end) {
    if (end == null) return 'In Progress';
    final duration = Duration(milliseconds: end - start);
    final minutes = duration.inMinutes;
    if (minutes >= 60) return '${minutes ~/ 60}h ${minutes % 60}m';
    return '$minutes min';
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, int sessionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete workout?'),
        content: const Text('This will permanently delete this workout and all its logged sets.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      HapticFeedback.heavyImpact();
      final repository = ref.read(workoutRepositoryProvider);
      await repository.deleteSession(sessionId);
      
      ref.invalidate(completedSessionsProvider);
      ref.invalidate(weeklyStatsProvider);
      ref.invalidate(weeklyVolumeChartProvider);
      ref.invalidate(recentSessionsProvider);
      
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
