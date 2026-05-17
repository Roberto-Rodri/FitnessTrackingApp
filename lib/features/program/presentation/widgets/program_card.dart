import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/program.dart';
import '../../domain/entities/program_day.dart';
import '../controllers/program_providers.dart';
import 'cycle_progress_strip.dart';
import '../../../../core/widgets/pressable_card.dart';

class ProgramCard extends ConsumerWidget {
  final Program program;
  final List<ProgramDay> days;
  final int? currentDayIndex;
  final Set<int> completedDayIndices;
  final String? nextUpLabel;
  final Map<int, String>? dayBodyParts;
  final VoidCallback onTap;

  const ProgramCard({
    super.key,
    required this.program,
    required this.days,
    this.currentDayIndex,
    required this.completedDayIndices,
    this.nextUpLabel,
    this.dayBodyParts,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PressableCard(
      onTap: onTap,
      child: program.isActive ? _buildActive(context, ref) : _buildInactive(context, ref),
    );
  }

  Widget _buildActive(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
          color: AppTheme.bg1,
          borderRadius: BorderRadius.circular(16),
          border: const Border(
            left: BorderSide(color: AppTheme.amber, width: 3),
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    program.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.txt0,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.amber.withValues(alpha: 0.1),
                    border: Border.all(color: AppTheme.amber.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: AppTheme.amber,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildMenuButton(context, ref),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${program.cycleLengthDays}-day cycle',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.txt2,
              ),
            ),
            const SizedBox(height: 16),
            CycleProgressStrip(
              days: days,
              currentDayIndex: currentDayIndex ?? program.currentDayIndex,
              completedDayIndices: completedDayIndices,
              dayBodyParts: dayBodyParts,
            ),
            const SizedBox(height: 16),
            if (nextUpLabel != null)
              Text(
                'Next up: $nextUpLabel ›',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.txt1,
                ),
              ),
          ],
        ),
      );
  }

  Widget _buildInactive(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
          color: AppTheme.bg1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.bg3),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.txt0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${program.cycleLengthDays}-day cycle',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.txt2,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                final repository = ref.read(programRepositoryProvider);
                await repository.setActiveProgram(program.id!);
                ref.invalidate(allProgramsProvider);
                ref.invalidate(activeProgramProvider);
                ref.invalidate(currentProgramDayProvider);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.bg3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Set active',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.amber,
                ),
              ),
            ),
            const SizedBox(width: 4),
            _buildMenuButton(context, ref),
          ],
        ),
      );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete program?'),
        content: Text('This will delete "${program.name}" and its cycle schedule. Your routines will not be affected.'),
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
      final repository = ref.read(programRepositoryProvider);
      await repository.deleteProgram(program.id!);
      ref.invalidate(allProgramsProvider);
      ref.invalidate(activeProgramProvider);
      ref.invalidate(currentProgramDayProvider);
      ref.invalidate(completedProgramDaysProvider);
    }
  }

  Widget _buildMenuButton(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AppTheme.txt2, size: 20),
      onSelected: (value) {
        if (value == 'edit') {
          onTap();
        } else if (value == 'delete') {
          _confirmDelete(context, ref);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ),
        ),
      ],
    );
  }
}
