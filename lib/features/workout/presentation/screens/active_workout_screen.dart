import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/workout_providers.dart';
import '../widgets/active_exercise_card.dart';
import '../widgets/media_control_bar.dart';

class ActiveWorkoutScreen extends ConsumerWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(workoutSessionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Workout'),
        centerTitle: true,
      ),
      body: sessionState.when(
        data: (activeState) {
          if (activeState.sessionId == null) {
            return const Center(child: Text('No active session. Go back.'));
          }

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          ActiveExerciseCard(
                            exerciseId: 1, // Matches seeded 'Squat'
                            exerciseName: 'Squat',
                            // Filter completedSets belonging to this exercise
                            completedSets: activeState.sets.where((s) => s.exerciseId == 1).toList(),
                          ),
                          ActiveExerciseCard(
                            exerciseId: 2, // Matches seeded 'Bench Press'
                            exerciseName: 'Bench Press',
                            completedSets: activeState.sets.where((s) => s.exerciseId == 2).toList(),
                          ),
                          ActiveExerciseCard(
                            exerciseId: 3, // Matches seeded 'Deadlift'
                            exerciseName: 'Deadlift',
                            completedSets: activeState.sets.where((s) => s.exerciseId == 3).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')), // Crucial for debugging
      ),
      bottomNavigationBar: const MediaControlBar(),
    );
  }
}
