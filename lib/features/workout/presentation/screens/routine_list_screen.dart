import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routing/router.dart';
import '../../../../core/theme/theme.dart';
import '../controllers/workout_providers.dart';
import '../widgets/routine_card.dart';
import '../widgets/skeleton_loading.dart';
import '../widgets/error_state.dart';
import '../widgets/empty_state.dart';
import '../../../program/presentation/controllers/program_providers.dart';
import '../../../program/presentation/widgets/program_card.dart';

class RoutineListScreen extends ConsumerWidget {
  const RoutineListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(routineListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Routines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fitness_center),
            onPressed: () {
              context.pushNamed(RouteNames.exerciseLibrary);
            },
          ),
        ],
      ),
      body: _buildBody(context, ref, routinesAsync),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final repository = ref.read(workoutRepositoryProvider);
          final newId = await repository.createRoutine('New Routine');
          ref.invalidate(routineListProvider);
          if (!context.mounted) return;
          context.pushNamed(
            RouteNames.routineEdit,
            pathParameters: {'routineId': newId.toString()},
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, AsyncValue routinesAsync) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProgramsSection(context, ref),
        const SizedBox(height: 24),
        const Divider(color: AppTheme.bg3, height: 1),
        const SizedBox(height: 24),
        _buildRoutinesSection(context, ref, routinesAsync),
      ],
    );
  }

  Widget _buildProgramsSection(BuildContext context, WidgetRef ref) {
    final allProgramsAsync = ref.watch(allProgramsProvider);
    final completedDaysAsync = ref.watch(completedProgramDaysProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'PROGRAMS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.txt2,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(width: 8),
            if (allProgramsAsync.hasValue && allProgramsAsync.value!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.bg2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  allProgramsAsync.value!.length.toString(),
                  style: const TextStyle(fontSize: 10, color: AppTheme.txt2, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        allProgramsAsync.when(
          data: (programs) {
            if (programs.isEmpty) {
              return _buildEmptyProgramsCard(context);
            }

            final activePrograms = programs.where((p) => p.isActive).toList();
            final inactivePrograms = programs.where((p) => !p.isActive).toList();
            final completedDays = completedDaysAsync.value ?? <int>{};

            return Column(
              children: [
                if (activePrograms.isNotEmpty) ...[
                  // The detail provider gives us the days for the active program
                  Consumer(
                    builder: (context, ref, child) {
                      final detailAsync = ref.watch(programDetailProvider(activePrograms.first.id!));
                      return detailAsync.when(
                        data: (detail) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ProgramCard(
                            program: detail.program,
                            days: detail.days,
                            completedDayIndices: completedDays,
                            nextUpLabel: detail.days.firstWhere((d) => d.dayIndex == detail.program.currentDayIndex, orElse: () => detail.days.first).label,
                            onTap: () => context.pushNamed(
                              RouteNames.programEdit,
                              pathParameters: {'programId': detail.program.id.toString()},
                            ),
                          ),
                        ),
                        loading: () => const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: SkeletonRoutineCard(), // Reusing skeleton
                        ),
                        error: (e, st) => ErrorCard(message: e.toString()),
                      );
                    },
                  ),
                ],
                for (final program in inactivePrograms)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ProgramCard(
                      program: program,
                      days: const [], // Inactive cards don't show strips
                      completedDayIndices: const {},
                      onTap: () => context.pushNamed(
                        RouteNames.programEdit,
                        pathParameters: {'programId': program.id.toString()},
                      ),
                    ),
                  ),
                _buildCreateProgramButton(context),
              ],
            );
          },
          loading: () => const SkeletonRoutineCard(),
          error: (e, st) => ErrorCard(
            message: e.toString(),
            onRetry: () => ref.invalidate(allProgramsProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyProgramsCard(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed(RouteNames.programNew),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bg1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.bg3), // solid instead of dashed natively
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.add_circle_outline, color: AppTheme.amber, size: 20),
                SizedBox(width: 8),
                Text(
                  'Set up a training program',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.amber,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Organize your routines into a repeating cycle',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.txt2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateProgramButton(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed(RouteNames.programNew),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.bg3),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: AppTheme.amber, size: 18),
            SizedBox(width: 8),
            Text(
              'Create program',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutinesSection(BuildContext context, WidgetRef ref, AsyncValue routinesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ROUTINES',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.txt2,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 12),
        routinesAsync.when(
          data: (routines) {
            if (routines.isEmpty) {
              return EmptyState(
                icon: const Icon(Icons.assignment_outlined, color: AppTheme.amber, size: 32),
                headline: 'No routines yet',
                subtitle: 'Build your first routine to get started.',
                ctaLabel: 'Create routine',
                onCtaTap: () => context.pushNamed(RouteNames.routineNew),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: routines.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final routine = routines[index];
                return RoutineCard(
                  routine: routine,
                  canDelete: routines.length > 1,
                  onTap: () {
                    context.pushNamed(
                      RouteNames.routineEdit,
                      pathParameters: {'routineId': routine.id.toString()},
                    );
                  },
                  onDelete: () async {
                    final repository = ref.read(workoutRepositoryProvider);
                    await repository.deleteRoutine(routine.id);
                    ref.invalidate(routineListProvider);
                  },
                );
              },
            );
          },
          loading: () => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => const SkeletonRoutineCard(),
          ),
          error: (err, stack) => ErrorCard(
            message: err.toString(),
            onRetry: () => ref.invalidate(routineListProvider),
          ),
        ),
      ],
    );
  }
}
