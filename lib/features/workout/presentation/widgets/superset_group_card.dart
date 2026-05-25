import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/routine_exercise_detail.dart';
import '../../domain/entities/workout_set.dart';
import '../../domain/entities/exercise.dart';
import 'active_exercise_card.dart';

class SupersetGroupCard extends StatelessWidget {
  final List<RoutineExerciseDetail> exercises;
  final int? activeExerciseId;
  final List<WorkoutSet> allSets;
  final Map<int, Map<String, dynamic>> bestSets;
  final Map<int, Map<String, dynamic>> latestSetsGlobal;
  final Map<int, Map<String, dynamic>> latestSetsRoutine;
  final bool useRoutineLatest;
  final Map<int, List<Exercise>> alternatives;

  const SupersetGroupCard({
    super.key,
    required this.exercises,
    required this.activeExerciseId,
    required this.allSets,
    required this.bestSets,
    required this.latestSetsGlobal,
    required this.latestSetsRoutine,
    required this.useRoutineLatest,
    required this.alternatives,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: AppTheme.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              _getGroupLabel(exercises.length),
              style: AppTheme.monoSmall(color: AppTheme.amber).copyWith(fontSize: 10),
            ),
          ),
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 3,
                margin: const EdgeInsets.only(left: 4, right: 8, bottom: 12),
                decoration: BoxDecoration(
                  color: AppTheme.amber,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: exercises.map((ex) {
                    final isCurrentActive = activeExerciseId == ex.exerciseId;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCurrentActive)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_right_alt, color: AppTheme.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Next',
                                  style: AppTheme.monoSmall(color: AppTheme.amber).copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ActiveExerciseCard(
                          exerciseId: ex.exerciseId,
                          exerciseName: ex.exerciseName,
                          targetSetsAndReps: '${ex.targetSets} × ${ex.targetReps}',
                          completedSets: allSets.where((s) => s.exerciseId == ex.exerciseId).toList(),
                          weightUnit: ex.weightUnit,
                          bodyPart: ex.bodyPart,
                          bestSet: bestSets[ex.exerciseId],
                          latestSetGlobal: latestSetsGlobal[ex.exerciseId],
                          latestSetRoutine: latestSetsRoutine[ex.exerciseId],
                          useRoutineLatest: useRoutineLatest,
                          alternatives: alternatives[ex.exerciseId] ?? [],
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getGroupLabel(int count) {
    if (count == 2) return 'SUPERSET';
    if (count == 3) return 'TRISET';
    return 'CIRCUIT';
  }
}
