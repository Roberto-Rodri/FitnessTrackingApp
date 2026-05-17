import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../controllers/workout_providers.dart';
import '../../domain/entities/exercise.dart';

class AlternativePickerSheet extends ConsumerStatefulWidget {
  final int currentExerciseId;
  final List<int> existingAlternativeIds;

  const AlternativePickerSheet({
    super.key,
    required this.currentExerciseId,
    required this.existingAlternativeIds,
  });

  @override
  ConsumerState<AlternativePickerSheet> createState() => _AlternativePickerSheetState();
}

class _AlternativePickerSheetState extends ConsumerState<AlternativePickerSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allExercisesAsync = ref.watch(allExercisesProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Link Alternative',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.txt2),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.txt2),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: allExercisesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.amber)),
              error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(color: theme.colorScheme.error))),
              data: (exercises) {
                // Filter out current, existing alternatives, and match search
                var filtered = exercises.where((e) =>
                    e.id != widget.currentExerciseId &&
                    !widget.existingAlternativeIds.contains(e.id) &&
                    e.name.toLowerCase().contains(_searchQuery)).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'No exercises found.',
                      style: TextStyle(color: AppTheme.txt2),
                    ),
                  );
                }

                // Group by body part
                final grouped = <String, List<Exercise>>{};
                for (var ex in filtered) {
                  grouped.putIfAbsent(ex.bodyPart, () => []).add(ex);
                }

                final bodyParts = grouped.keys.toList()..sort();

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: bodyParts.length,
                  itemBuilder: (context, index) {
                    final bodyPart = bodyParts[index];
                    final exercisesInPart = grouped[bodyPart]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: Text(
                            bodyPart.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppTheme.amber,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...exercisesInPart.map((ex) => ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                              title: Text(ex.name, style: TextStyle(color: theme.colorScheme.onSurface)),
                              onTap: () {
                                Navigator.pop(context, ex);
                              },
                            )),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
