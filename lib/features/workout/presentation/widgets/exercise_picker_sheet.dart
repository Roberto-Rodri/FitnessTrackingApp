import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exercise.dart';
import '../controllers/workout_providers.dart';
import 'exercise_form_dialog.dart';
import '../../../../core/di/injection.dart';

class ExercisePickerSheet extends ConsumerStatefulWidget {
  final Function(Exercise?) onExerciseSelected;

  const ExercisePickerSheet({
    super.key,
    required this.onExerciseSelected,
  });

  @override
  ConsumerState<ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends ConsumerState<ExercisePickerSheet> {
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
            final bodyParts = ['All', ...exercises.map((e) => e.bodyPart).toSet().toList()..sort()];

            final filteredExercises = _selectedBodyPart == 'All'
                ? exercises
                : exercises.where((e) => e.bodyPart == _selectedBodyPart).toList();

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
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
                    'Add Exercise',
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
                    itemCount: filteredExercises.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ListTile(
                          leading: const Icon(Icons.add),
                          title: const Text(
                            'Create new exercise',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () async {
                            final result = await showExerciseFormDialog(context);
                            if (result == null) return;

                            final name = result['name'] as String;
                            final bodyPart = result['bodyPart'] as String;
                            final weightUnit = result['weightUnit'] as String;
                            final machineId = result['machineId'] as int?;

                            if (!context.mounted) return;

                            try {
                              final repository = ref.read(workoutRepositoryProvider);
                              final id = await repository.createExercise(name, bodyPart, weightUnit, machineId: machineId);

                              ref.invalidate(allExercisesProvider);
                              ref.invalidate(bodyPartsProvider);

                              final newExercise = Exercise(
                                id: id,
                                name: name,
                                bodyPart: bodyPart,
                                weightUnit: weightUnit,
                                machineId: machineId,
                              );

                              widget.onExerciseSelected(newExercise);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to add exercise: $e')),
                                );
                              }
                            }
                          },
                        );
                      }

                      final ex = filteredExercises[index - 1];

                      return ListTile(
                        title: Text(ex.name),
                        subtitle: Text(ex.bodyPart),
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          widget.onExerciseSelected(ex);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(child: Text('Error: $err')),
        );
      },
    );
  }
}
