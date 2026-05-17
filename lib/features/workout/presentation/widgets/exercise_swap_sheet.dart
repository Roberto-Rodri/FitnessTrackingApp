import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exercise.dart';
import '../controllers/workout_providers.dart';

class ExerciseSwapSheet extends ConsumerStatefulWidget {
  final int currentExerciseId;
  final Function(Exercise) onExerciseSelected;

  const ExerciseSwapSheet({
    super.key,
    required this.currentExerciseId,
    required this.onExerciseSelected,
  });

  @override
  ConsumerState<ExerciseSwapSheet> createState() => _ExerciseSwapSheetState();
}

class _ExerciseSwapSheetState extends ConsumerState<ExerciseSwapSheet> {
  String _selectedBodyPart = 'All';

  @override
  Widget build(BuildContext context) {
    final allExercisesAsync = ref.watch(allExercisesProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      builder: (context, scrollController) {
        return allExercisesAsync.when(
          data: (exercises) {
            if (exercises.isEmpty) {
              return const Center(child: Text('No exercises found.'));
            }

            final bodyParts = ['All', ...exercises.map((e) => e.bodyPart).toSet().toList()..sort()];

            final filteredExercises = _selectedBodyPart == 'All'
                ? exercises
                : exercises.where((e) => e.bodyPart == _selectedBodyPart).toList();

            return Column(
              children: [
                // Drag Handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Swap Exercise',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: bodyParts.map((bp) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(bp),
                          selected: _selectedBodyPart == bp,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedBodyPart = bp);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: filteredExercises.length,
                    itemBuilder: (context, index) {
                      final ex = filteredExercises[index];
                      final isActive = ex.id == widget.currentExerciseId;

                      return ListTile(
                        title: Text(
                          ex.name,
                          style: TextStyle(
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(ex.bodyPart),
                        trailing: isActive
                            ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                            : null,
                        tileColor: isActive
                            ? Theme.of(context).colorScheme.primaryContainer.withAlpha(76) // approx 0.3
                            : null,
                        onTap: () {
                          if (!isActive) {
                            HapticFeedback.mediumImpact();
                            widget.onExerciseSelected(ex);
                            Navigator.of(context).pop();
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(child: Text('Error: $err')),
        );
      },
    );
  }
}
