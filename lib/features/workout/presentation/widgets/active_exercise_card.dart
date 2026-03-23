import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/workout_set.dart';
import '../controllers/workout_providers.dart';

class ActiveExerciseCard extends ConsumerStatefulWidget {
  final int exerciseId;
  final String exerciseName;
  final List<WorkoutSet> completedSets;

  const ActiveExerciseCard({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.completedSets,
  });

  @override
  ConsumerState<ActiveExerciseCard> createState() => _ActiveExerciseCardState();
}

class _ActiveExerciseCardState extends ConsumerState<ActiveExerciseCard> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final FocusNode _weightFocus = FocusNode();
  final FocusNode _repsFocus = FocusNode();

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _weightFocus.dispose();
    _repsFocus.dispose();
    super.dispose();
  }

  void _logSet() {
    final weightStr = _weightController.text;
    final repsStr = _repsController.text;

    if (weightStr.isEmpty || repsStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter weight and reps')),
      );
      return;
    }

    final weight = double.tryParse(weightStr);
    final reps = int.tryParse(repsStr);

    if (weight == null || reps == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid input')),
      );
      return;
    }

    final newSet = WorkoutSet(
      sessionId: -1, // Will be overridden in notifier
      exerciseId: widget.exerciseId,
      weight: weight,
      reps: reps,
    );

    ref.read(workoutSessionNotifierProvider.notifier).logNewSet(newSet);
    
    // Clear inputs and keep focus on weight for next set
    _weightController.clear();
    _repsController.clear();
    _weightFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.exerciseName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: 'Swap Exercise',
                  onPressed: () {
                    // TODO: Implement Swap Logic
                  },
                )
              ],
            ),
            const Divider(),
            
            // Completed Sets List
            if (widget.completedSets.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Completed Sets',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ...widget.completedSets.asMap().entries.map((entry) {
                int idx = entry.key + 1;
                WorkoutSet set = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Set $idx', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('${set.weight} kg x ${set.reps} reps'),
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // Input Fields
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    focusNode: _weightFocus,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _repsFocus.requestFocus(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    focusNode: _repsFocus,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _logSet(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Log Set Button
            FilledButton.icon(
              onPressed: _logSet,
              icon: const Icon(Icons.add),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('LOG SET', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
