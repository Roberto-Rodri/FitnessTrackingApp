import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/theme.dart';
import '../controllers/workout_providers.dart';
import '../../domain/entities/exercise.dart';
import '../widgets/skeleton_loading.dart';
import '../widgets/error_state.dart';
import '../widgets/empty_state.dart';

class ExerciseSelectionScreen extends ConsumerStatefulWidget {
  final int routineId;

  const ExerciseSelectionScreen({super.key, required this.routineId});

  @override
  ConsumerState<ExerciseSelectionScreen> createState() => _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState extends ConsumerState<ExerciseSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Exercise>? _cachedAllExercises;
  List<Exercise>? _cachedFilteredExercises;
  String _cachedQuery = '';

  List<Exercise> _getFiltered(List<Exercise> allExercises, String query) {
    if (_cachedAllExercises == allExercises && _cachedQuery == query && _cachedFilteredExercises != null) {
      return _cachedFilteredExercises!;
    }
    _cachedAllExercises = allExercises;
    _cachedQuery = query;
    _cachedFilteredExercises = allExercises.where((e) => e.name.toLowerCase().contains(query)).toList();
    return _cachedFilteredExercises!;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addExercise(Exercise exercise, bool isAlreadyAdded) async {
    final repository = ref.read(workoutRepositoryProvider);
    
    if (isAlreadyAdded) {
      await repository.removeExerciseFromRoutine(widget.routineId, exercise.id!);
      ref.invalidate(routineExercisesProvider(widget.routineId));
      ref.invalidate(routineListProvider);

      if (mounted) {
        // Optional: ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from routine')));
      }
      return;
    }

    HapticFeedback.lightImpact();
    final nextOrder = await repository.getNextSequenceOrder(widget.routineId);
    await repository.addExerciseToRoutine(widget.routineId, exercise.id!, nextOrder, 3, '8-10', 90);
    
    ref.invalidate(routineExercisesProvider(widget.routineId));
    ref.invalidate(routineListProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${exercise.name} added')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allExercisesAsync = ref.watch(allExercisesProvider);
    final routineExercisesAsync = ref.watch(routineExercisesProvider(widget.routineId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Add Exercise',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(72),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                    prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.amber, width: 2),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          allExercisesAsync.when(
            data: (allExercises) {
              final addedIds = routineExercisesAsync.valueOrNull?.map((e) => e.exerciseId).toSet() ?? {};

              var filtered = _getFiltered(allExercises, _searchQuery);
              
              if (filtered.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icon(Icons.search_off, color: AppTheme.txt2, size: 32),
                    headline: 'No exercises found',
                    subtitle: 'Try a different search term or check the spelling.',
                    dim: true,
                  ),
                );
              }

              // Group by body part
              final Map<String, List<Exercise>> grouped = {};
              for (var ex in filtered) {
                grouped.putIfAbsent(ex.bodyPart, () => []).add(ex);
              }
              final sortedKeys = grouped.keys.toList()..sort();

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final groupName = sortedKeys[index];
                    final groupExercises = grouped[groupName]!;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                          color: theme.colorScheme.surface,
                          child: Text(
                            groupName.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppTheme.txt2,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        ...groupExercises.map((exercise) {
                          final isAdded = addedIds.contains(exercise.id);
                          return InkWell(
                            onTap: () => _addExercise(exercise, isAdded),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                border: Border(
                                  bottom: BorderSide(
                                    color: theme.colorScheme.surface,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    exercise.name,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: isAdded ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  if (isAdded)
                                    const Icon(Icons.check_circle, color: AppTheme.amber)
                                  else
                                    const Icon(Icons.add_circle_outline, color: AppTheme.txt2),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                  childCount: sortedKeys.length,
                ),
              );
            },
            loading: () => SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Bone(width: 80, height: 14),
                ),
                const SkeletonExerciseRow(),
                const SkeletonExerciseRow(),
                const SkeletonExerciseRow(),
              ]),
            ),
            error: (err, st) => SliverFillRemaining(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ErrorCard(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(allExercisesProvider),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
