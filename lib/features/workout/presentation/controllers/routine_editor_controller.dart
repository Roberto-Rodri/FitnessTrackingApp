import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/routine_exercise_detail.dart';
import '../../../../core/di/injection.dart';

part 'routine_editor_controller.g.dart';

class RoutineBlock {
  final int? supersetGroup;
  final List<RoutineExerciseDetail> exercises;

  RoutineBlock({
    required this.supersetGroup,
    required this.exercises,
  });
}

@riverpod
class RoutineEditor extends _$RoutineEditor {
  @override
  FutureOr<List<RoutineBlock>> build(int routineId) async {
    return _fetchAndGroupExercises();
  }

  Future<List<RoutineBlock>> _fetchAndGroupExercises() async {
    final repository = ref.read(workoutRepositoryProvider);
    final rawExercises = await repository.getExercisesForRoutine(routineId);
    
    final List<RoutineBlock> blocks = [];
    int? currentGroup;
    List<RoutineExerciseDetail> currentExercises = [];

    for (final ex in rawExercises) {
      if (ex.supersetGroup == null) {
        // Close current group if exists
        if (currentExercises.isNotEmpty) {
          blocks.add(RoutineBlock(supersetGroup: currentGroup, exercises: currentExercises));
          currentExercises = [];
        }
        // Add standalone block
        blocks.add(RoutineBlock(supersetGroup: null, exercises: [ex]));
      } else {
        if (currentGroup == ex.supersetGroup) {
          currentExercises.add(ex);
        } else {
          // Close previous group
          if (currentExercises.isNotEmpty) {
            blocks.add(RoutineBlock(supersetGroup: currentGroup, exercises: currentExercises));
          }
          currentGroup = ex.supersetGroup;
          currentExercises = [ex];
        }
      }
    }
    // Close remaining group
    if (currentExercises.isNotEmpty) {
      blocks.add(RoutineBlock(supersetGroup: currentGroup, exercises: currentExercises));
    }

    return blocks;
  }

  Future<void> linkExercises(int blockIndex1, int blockIndex2) async {
    final blocks = state.valueOrNull;
    if (blocks == null) return;

    final block1 = blocks[blockIndex1];
    final block2 = blocks[blockIndex2];

    final repository = ref.read(workoutRepositoryProvider);
    
    int newGroupId;
    if (block1.supersetGroup == null && block2.supersetGroup == null) {
      newGroupId = DateTime.now().millisecondsSinceEpoch;
    } else if (block1.supersetGroup != null && block2.supersetGroup == null) {
      newGroupId = block1.supersetGroup!;
    } else if (block1.supersetGroup == null && block2.supersetGroup != null) {
      newGroupId = block2.supersetGroup!;
    } else {
      // Both are in different groups, merge them to block1's group
      newGroupId = block1.supersetGroup!;
    }

    // Update DB
    for (final ex in block1.exercises) {
      await repository.updateSupersetGroup(routineId, ex.exerciseId, newGroupId);
    }
    for (final ex in block2.exercises) {
      await repository.updateSupersetGroup(routineId, ex.exerciseId, newGroupId);
    }

    // Refresh state
    ref.invalidateSelf();
    await future;
  }

  Future<void> unlinkExercise(int exerciseId) async {
    final blocks = state.valueOrNull;
    if (blocks == null) return;

    final repository = ref.read(workoutRepositoryProvider);
    
    // Unlink the target exercise
    await repository.updateSupersetGroup(routineId, exerciseId, null);

    // Check if the group only has 1 exercise left, if so, dissolve it
    final rawExercises = await repository.getExercisesForRoutine(routineId);
    final groups = <int, int>{};
    for (final ex in rawExercises) {
      if (ex.supersetGroup != null) {
        groups[ex.supersetGroup!] = (groups[ex.supersetGroup!] ?? 0) + 1;
      }
    }

    for (final ex in rawExercises) {
      if (ex.supersetGroup != null && groups[ex.supersetGroup!] == 1) {
        await repository.updateSupersetGroup(routineId, ex.exerciseId, null);
      }
    }

    // Refresh state
    ref.invalidateSelf();
    await future;
  }

  Future<void> reorderBlocks(int oldIndex, int newIndex) async {
    final blocks = state.valueOrNull?.toList();
    if (blocks == null) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = blocks.removeAt(oldIndex);
    blocks.insert(newIndex, item);

    // Flatten blocks to order
    final newOrderIds = <int>[];
    for (final block in blocks) {
      for (final ex in block.exercises) {
        newOrderIds.add(ex.exerciseId);
      }
    }

    final repository = ref.read(workoutRepositoryProvider);
    await repository.updateExerciseOrder(routineId, newOrderIds);
    
    // Refresh state
    ref.invalidateSelf();
    await future;
  }
}
