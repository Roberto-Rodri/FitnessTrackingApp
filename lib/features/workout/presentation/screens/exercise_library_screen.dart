import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/theme.dart';
import '../controllers/workout_providers.dart';
import '../../domain/entities/exercise.dart';
import '../widgets/exercise_form_dialog.dart';
import '../widgets/alternative_picker_sheet.dart';
import '../widgets/skeleton_loading.dart';
import '../widgets/error_state.dart';
import '../widgets/empty_state.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
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

  Future<void> _addOrEditExercise({Exercise? exercise}) async {
    final result = await showExerciseFormDialog(context, existingExercise: exercise);
    if (result != null) {
      final repository = ref.read(workoutRepositoryProvider);
      if (exercise == null) {
        await repository.createExercise(result['name']!, result['bodyPart']!, result['weightUnit']!);
      } else {
        await repository.updateExercise(exercise.id!, result['name']!, result['bodyPart']!, result['weightUnit']!);
      }
      ref.invalidate(allExercisesProvider);
      ref.invalidate(bodyPartsProvider);
      ref.invalidate(routineListProvider);
    }
  }

  Future<void> _deleteExercise(Exercise exercise) async {
    final repository = ref.read(workoutRepositoryProvider);
    final usageCount = await repository.getExerciseUsageCount(exercise.id!);
    final historyCount = await repository.getExerciseHistoryCount(exercise.id!);

    if (!mounted) return;

    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: theme.colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 32.0, bottom: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Delete Exercise?',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to delete "${exercise.name}"?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                if (usageCount > 0)
                  Text(
                    '⚠ Used in $usageCount routine(s). It will be removed from them.',
                    style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                if (historyCount > 0)
                  Text(
                    '⚠ Has history ($historyCount sets). All related sets will be deleted.',
                    style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      HapticFeedback.heavyImpact();
      await repository.deleteExercise(exercise.id!);
      ref.invalidate(allExercisesProvider);
      ref.invalidate(bodyPartsProvider);
      ref.invalidate(routineListProvider);
    }
  }

  Future<void> _showActionSheet(Exercise exercise) async {
    final theme = Theme.of(context);
    final repository = ref.read(workoutRepositoryProvider);
    final alternatives = await repository.getAlternativesForExercise(exercise.id!);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                exercise.name,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: AppTheme.amber),
              title: const Text('Edit Exercise'),
              onTap: () {
                Navigator.pop(context);
                _addOrEditExercise(exercise: exercise);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: theme.colorScheme.error),
              title: Text('Delete Exercise', style: TextStyle(color: theme.colorScheme.error)),
              onTap: () {
                Navigator.pop(context);
                _deleteExercise(exercise);
              },
            ),
            ListTile(
              leading: Icon(Icons.link, color: theme.colorScheme.primary),
              title: const Text('Link Alternative'),
              onTap: () async {
                Navigator.pop(context);
                final selected = await showModalBottomSheet<Exercise>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AlternativePickerSheet(
                    currentExerciseId: exercise.id!,
                    existingAlternativeIds: alternatives.map((e) => e.id!).toList(),
                  ),
                );

                if (selected != null) {
                  if (!context.mounted) return;
                  await repository.linkAlternativeExercises(exercise.id!, selected.id!);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Linked to ${selected.name}')),
                  );
                  // Refresh just by re-opening or forcing an update if we wanted
                }
              },
            ),
            if (alternatives.isNotEmpty) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ALTERNATIVES',
                    style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.txt3, letterSpacing: 1.2),
                  ),
                ),
              ),
              ...alternatives.map((alt) => ListTile(
                    title: Text(alt.name, style: const TextStyle(color: AppTheme.txt2)),
                    trailing: IconButton(
                      icon: Icon(Icons.link_off, color: theme.colorScheme.error, size: 20),
                      onPressed: () async {
                        Navigator.pop(context);
                        await repository.unlinkAlternativeExercises(exercise.id!, alt.id!);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Unlinked ${alt.name}')),
                        );
                      },
                    ),
                  )),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allExercisesAsync = ref.watch(allExercisesProvider);
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
              'Exercise Library',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
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
              if (allExercises.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyState(
                    icon: const Icon(Icons.fitness_center, color: AppTheme.txt2, size: 32),
                    headline: 'No exercises',
                    subtitle: 'Add your first exercise to start building routines.',
                    ctaLabel: 'Add exercise',
                    onCtaTap: () => _addOrEditExercise(),
                  ),
                );
              }

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
                          return InkWell(
                            onTap: () => _showActionSheet(exercise),
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
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const Icon(Icons.more_vert, color: AppTheme.txt2),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        onPressed: () => _addOrEditExercise(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
