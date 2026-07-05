import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/workout_session_summary.dart';
import '../controllers/workout_providers.dart';
import 'pr_badge.dart';
import '../../../../core/widgets/pressable_card.dart';

class SessionHistoryCard extends ConsumerWidget {
  final WorkoutSessionSummary summary;
  final VoidCallback onTap;

  const SessionHistoryCard({
    super.key,
    required this.summary,
    required this.onTap,
  });

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekdayStr = weekdays[date.weekday - 1];
    final monthStr = months[date.month - 1];
    return '$weekdayStr, $monthStr ${date.day}, ${date.year}';
  }

  String _formatDuration(int start, int? end) {
    if (end == null) return 'In Progress';
    final duration = Duration(milliseconds: end - start);
    final minutes = duration.inMinutes;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '${hours}h ${mins}m';
    }
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = summary.session;
    final prCountAsync = ref.watch(sessionPRCountProvider(session.id!));
    
    return PressableCard(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            session.routineNameSnapshot,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (prCountAsync.value != null && prCountAsync.value! > 0) ...[
                          const SizedBox(width: 8),
                          PRBadge(size: PRBadgeSize.sm, count: prCountAsync.value!),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    _formatDate(session.startTimestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoItem(
                    icon: Icons.timer_outlined,
                    label: _formatDuration(session.startTimestamp, session.endTimestamp),
                  ),
                  _InfoItem(
                    icon: Icons.fitness_center,
                    label: '${summary.totalVolume.toStringAsFixed(0)} kg',
                  ),
                  _InfoItem(
                    icon: Icons.repeat,
                    label: '${summary.totalSets} sets',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
