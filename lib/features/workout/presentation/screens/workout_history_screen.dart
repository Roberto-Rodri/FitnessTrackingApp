import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/router.dart';
import '../../../../core/theme/theme.dart';
import '../controllers/workout_providers.dart';
import '../widgets/session_history_card.dart';
import '../widgets/skeleton_loading.dart';
import '../widgets/error_state.dart';
import '../widgets/empty_state.dart';

class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(filteredSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: HistoryFilter.values.map((filter) {
                final isSelected = ref.watch(historyFilterProvider) == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_filterLabel(filter)),
                    selected: isSelected,
                    onSelected: (_) => ref.read(historyFilterProvider.notifier).state = filter,
                    selectedColor: AppTheme.amber.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppTheme.amber : AppTheme.txt2,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.outline,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: sessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  final filter = ref.read(historyFilterProvider);
                  return Padding(
                    padding: const EdgeInsets.only(top: 64.0),
                    child: EmptyState(
                      icon: const Icon(Icons.schedule, color: AppTheme.amber, size: 32),
                      headline: filter == HistoryFilter.all ? 'No workouts yet' : 'No workouts found',
                      subtitle: filter == HistoryFilter.all 
                        ? 'Your training log is empty. Time to hit the iron!'
                        : 'No workouts match the selected filter.',
                      ctaLabel: filter == HistoryFilter.all ? 'Start workout' : null,
                      onCtaTap: filter == HistoryFilter.all 
                        ? () => context.pushNamed(RouteNames.activeWorkout)
                        : null,
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final summary = sessions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: SessionHistoryCard(
                        summary: summary,
                        onTap: () {
                          context.pushNamed(
                            RouteNames.sessionDetail,
                            pathParameters: {'sessionId': summary.session.id.toString()},
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 3,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => const SkeletonHistoryCard(),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: ErrorCard(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(filteredSessionsProvider),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(HistoryFilter filter) {
    switch (filter) {
      case HistoryFilter.all: return 'All';
      case HistoryFilter.thisWeek: return 'This week';
      case HistoryFilter.thisMonth: return 'This month';
    }
  }
}
