import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/theme.dart';
import '../controllers/workout_providers.dart';
import '../../domain/entities/routine_exercise_detail.dart';
import '../widgets/edit_targets_dialog.dart';
import '../widgets/routine_exercise_tile.dart';

class RoutineEditScreen extends ConsumerStatefulWidget {
  final int? routineId;

  const RoutineEditScreen({super.key, this.routineId});

  @override
  ConsumerState<RoutineEditScreen> createState() => _RoutineEditScreenState();
}

class _RoutineEditScreenState extends ConsumerState<RoutineEditScreen> {
  bool _hasFiredDragHaptic = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _initializeName();
  }

  Future<void> _initializeName() async {
    if (widget.routineId != null) {
      final routinesList = await ref.read(routineListProvider.future);
      final routine = routinesList.firstWhere((r) => r.id == widget.routineId);
      _nameController.text = routine.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveRoutine() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Routine name cannot be empty')),
      );
      return;
    }

    final routineId = widget.routineId;
    final repository = ref.read(workoutRepositoryProvider);
    if (routineId != null) {
      await repository.updateRoutineName(routineId, name);
    } else {
      await repository.createRoutine(name);
    }
    
    ref.invalidate(routineListProvider);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveRoutine,
            child: Text('Save', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: TextField(
              controller: _nameController,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Routine Name',
                hintStyle: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ),
          const Divider(),
          Expanded(
            child: _buildExerciseList(theme),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        onPressed: _navigateToAddExercise,
        icon: const Icon(Icons.add),
        label: const Text('Add Exercise', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildExerciseList(ThemeData theme) {
    final routineId = widget.routineId;
    if (routineId == null) {
      return Center(
        child: Text(
          'Save the routine first to add exercises.',
          style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt2),
        ),
      );
    }

    final exercisesAsync = ref.watch(routineExercisesProvider(routineId));
    
    return exercisesAsync.when(
      data: (exercises) {
        if (exercises.isEmpty) {
          return Center(
            child: Text(
              'No exercises yet. Tap + to add.',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt2),
            ),
          );
        }

        return ReorderableListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80, left: 16, right: 16),
          itemCount: exercises.length,
          onReorder: (oldIndex, newIndex) => _onReorder(exercises, oldIndex, newIndex),
          proxyDecorator: (child, index, animation) {
            if (!_hasFiredDragHaptic) {
              HapticFeedback.mediumImpact();
              _hasFiredDragHaptic = true;
            }
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final scale = Tween<double>(begin: 1.0, end: 1.025).evaluate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                );
                return Transform.scale(
                  scale: scale,
                  child: Material(
                    elevation: 8 * animation.value,
                    shadowColor: Colors.black54,
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.transparent,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.amber.withValues(alpha: animation.value),
                          width: 2 * animation.value,
                        ),
                      ),
                      child: child,
                    ),
                  ),
                );
              },
              child: child,
            );
          },
          itemBuilder: (context, index) {
            final ex = exercises[index];
            return RoutineExerciseTile(
              key: ValueKey(ex.exerciseId),
              exercise: ex,
              index: index,
              onEditTargets: () => _editTargets(ex),
              onDismissed: () async {
                HapticFeedback.heavyImpact();
                final repository = ref.read(workoutRepositoryProvider);
                await repository.removeExerciseFromRoutine(routineId, ex.exerciseId);
                ref.invalidate(routineExercisesProvider(routineId));
                ref.invalidate(routineListProvider);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  void _navigateToAddExercise() {
    final routineId = widget.routineId;
    if (routineId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please save the routine first.')),
      );
      return;
    }
    context.pushNamed(RouteNames.exerciseSelection, pathParameters: {'routineId': routineId.toString()});
  }

  Future<void> _editTargets(RoutineExerciseDetail ex) async {
    final routineId = widget.routineId;
    if (routineId == null) return;
    
    final result = await showEditTargetsDialog(context, ex.targetSets, ex.targetReps, ex.restSeconds);
    if (result != null) {
      final repository = ref.read(workoutRepositoryProvider);
      await repository.updateExerciseTargets(routineId, ex.exerciseId, result['sets'] as int, result['reps'] as String);
      await repository.updateExerciseRestTime(routineId, ex.exerciseId, result['restSeconds'] as int);
      ref.invalidate(routineExercisesProvider(routineId));
    }
  }

  Future<void> _onReorder(List<RoutineExerciseDetail> currentList, int oldIndex, int newIndex) async {
    HapticFeedback.lightImpact();
    _hasFiredDragHaptic = false;
    final routineId = widget.routineId;
    if (routineId == null) return;
    
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final item = currentList.removeAt(oldIndex);
    currentList.insert(newIndex, item);
    
    final newOrderIds = currentList.map((e) => e.exerciseId).toList();
    
    final repository = ref.read(workoutRepositoryProvider);
    await repository.updateExerciseOrder(routineId, newOrderIds);
    ref.invalidate(routineExercisesProvider(routineId));
  }
}
