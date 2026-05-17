import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/routine_summary.dart';
import '../../../../core/widgets/pressable_card.dart';

class RoutineCard extends StatelessWidget {
  final RoutineSummary routine;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool canDelete;

  const RoutineCard({
    super.key,
    required this.routine,
    required this.onTap,
    required this.onDelete,
    required this.canDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
                    child: Text(
                      routine.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: canDelete ? theme.colorScheme.error : theme.disabledColor,
                    onPressed: canDelete ? () => _confirmDelete(context) : () => _showCannotDeleteMessage(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${routine.exerciseCount} exercises',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              if (routine.exerciseNames != null && routine.exerciseNames!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  routine.exerciseNames!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (routine.exerciseCount == 0 || routine.exerciseNames == null || routine.exerciseNames!.isEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'No exercises yet',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ));
  }

  void _showCannotDeleteMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cannot delete the only remaining routine.')),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Routine?'),
        content: Text('Are you sure you want to delete "${routine.name}"? This action cannot be undone.'),
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
      onDelete();
    }
  }
}
