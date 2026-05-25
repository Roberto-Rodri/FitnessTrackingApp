import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/program_day.dart';
import '../controllers/program_providers.dart';
import '../widgets/cycle_day_card.dart';
import '../widgets/template_picker.dart';
import '../widgets/cycle_progress_strip.dart';
import '../../../workout/presentation/controllers/workout_providers.dart';

class ProgramEditScreen extends ConsumerStatefulWidget {
  final int? programId;

  const ProgramEditScreen({super.key, this.programId});

  @override
  ConsumerState<ProgramEditScreen> createState() => _ProgramEditScreenState();
}

class _ProgramEditScreenState extends ConsumerState<ProgramEditScreen> {
  bool _hasFiredDragHaptic = false;
  late TextEditingController _nameController;
  final List<ProgramDay> _days = [];
  final List<Key> _dayKeys = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    
    if (widget.programId != null) {
      _loadProgram();
    }
  }

  Future<void> _loadProgram() async {
    final pid = widget.programId;
    if (pid == null) return;
    
    setState(() => _isLoading = true);
    try {
      final detail = await ref.read(programDetailProvider(pid).future);
      setState(() {
        _nameController.text = detail.program.name;
        _days.addAll(detail.days);
        _dayKeys.addAll(detail.days.map((_) => UniqueKey()));
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load program: $e')));
        context.pop();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onTemplateSelected(TemplateConfig template) {
    setState(() {
      _nameController.text = template.defaultName;
      _days.clear();
      _dayKeys.clear();
      for (int i = 0; i < template.days.length; i++) {
        final dayData = template.days[i];
        _days.add(ProgramDay(
          programId: 0,
          dayIndex: i,
          routineId: null, // routines aren't assigned yet
          label: dayData.$1,
        ));
        _dayKeys.add(UniqueKey());
      }
    });
  }

  void _onStartFromScratch() {
    setState(() {
      _days.clear();
      _dayKeys.clear();
      // add one empty day just to start
      _days.add(const ProgramDay(
        programId: 0,
        dayIndex: 0,
        routineId: null,
        label: 'Day 1',
      ));
      _dayKeys.add(UniqueKey());
    });
  }

  void _addWorkoutDay() {
    setState(() {
      final newIndex = _days.length;
      _days.add(ProgramDay(
        programId: 0,
        dayIndex: newIndex,
        routineId: null,
        label: 'Day ${newIndex + 1}',
      ));
      _dayKeys.add(UniqueKey());
    });
  }

  void _addRestDay() {
    setState(() {
      final newIndex = _days.length;
      _days.add(ProgramDay(
        programId: 0,
        dayIndex: newIndex,
        routineId: null,
        label: 'Rest',
      ));
      _dayKeys.add(UniqueKey());
    });
  }

  void _editDayLabel(int index) async {
    final controller = TextEditingController(text: _days[index].label);
    final newLabel = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh, // bg2
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Rename day', style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
        )),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Day name',
            filled: true,
            fillColor: Theme.of(context).colorScheme.outline, // bg3
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.txt2)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.amber,
            ),
            child: const Text('Save', style: TextStyle(
              color: Color(0xFF1C1000), fontWeight: FontWeight.w700,
            )),
          ),
        ],
      ),
    );
    
    if (newLabel != null && newLabel.isNotEmpty && newLabel != _days[index].label) {
      setState(() {
        _days[index] = _days[index].copyWith(label: newLabel);
      });
    }
    controller.dispose();
  }

  void _deleteDay(int index) {
    setState(() {
      _days.removeAt(index);
      _dayKeys.removeAt(index);
      for (int i = 0; i < _days.length; i++) {
        _days[i] = _days[i].copyWith(dayIndex: i);
      }
    });
  }

  Future<void> _assignRoutine(int index) async {
    final routinesAsync = ref.read(routineListProvider);
    if (!routinesAsync.hasValue) return;
    
    final routines = routinesAsync.value!;

    final selectedRoutineId = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppTheme.bg1,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.bg3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Assign Routine',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.txt0),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: routines.length,
                itemBuilder: (context, i) {
                  final routine = routines[i];
                  return ListTile(
                    title: Text(routine.name, style: const TextStyle(color: AppTheme.txt0)),
                    subtitle: Text('${routine.exerciseCount} exercises', style: const TextStyle(color: AppTheme.txt2)),
                    onTap: () => Navigator.pop(context, routine.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (selectedRoutineId != null) {
      setState(() {
        _days[index] = _days[index].copyWith(routineId: selectedRoutineId);
      });
    }
  }

  Future<void> _saveProgram() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a program name')));
      return;
    }
    
    final hasWorkoutDay = _days.any((d) => d.routineId != null || !d.label.toLowerCase().contains('rest'));
    if (!hasWorkoutDay) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one workout day to the cycle')));
      return;
    }

    try {
      final repository = ref.read(programRepositoryProvider);
      final pid = widget.programId;
      if (pid == null) {
        await repository.createProgram(name, _days);
      } else {
        await repository.updateProgram(pid, name, _days);
      }
      
      ref.invalidate(allProgramsProvider);
      ref.invalidate(activeProgramProvider);
      ref.invalidate(currentProgramDayProvider);
      if (pid != null) {
        ref.invalidate(programDetailProvider(pid));
      }
      
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving program: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.bg0,
        body: Center(child: CircularProgressIndicator(color: AppTheme.amber)),
      );
    }

    final routinesAsync = ref.watch(routineListProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg0,
      appBar: AppBar(
        backgroundColor: AppTheme.bg0,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(color: AppTheme.bg2, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: const Icon(Icons.arrow_back, color: AppTheme.txt1, size: 20),
            ),
          ),
        ),
        title: Text(
          widget.programId == null ? 'New Program' : 'Edit Program',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.txt0),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: FilledButton(
              onPressed: _saveProgram,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.amber,
                foregroundColor: AppTheme.bg0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.txt0),
                    decoration: InputDecoration(
                      hintText: 'Program name',
                      hintStyle: const TextStyle(color: AppTheme.txt3),
                      filled: true,
                      fillColor: AppTheme.bg1,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  if (widget.programId == null && _days.isEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('Start from a template', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.txt1)),
                    const SizedBox(height: 12),
                    TemplatePicker(
                      onTemplateSelected: _onTemplateSelected,
                      onStartFromScratch: _onStartFromScratch,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_days.isNotEmpty || widget.programId != null) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text('Cycle builder', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.txt1)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverReorderableList(
                itemCount: _days.length,
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
                  final day = _days[index];
                  String? routineName;
                  List<String>? bodyParts;

                  if (day.routineId != null && routinesAsync.hasValue) {
                    final matchingRoutine = routinesAsync.value!.cast<dynamic>().firstWhere(
                      (r) => r.id == day.routineId, 
                      orElse: () => null,
                    );
                    if (matchingRoutine != null) {
                      routineName = matchingRoutine.name;
                      // Just display the first few body parts or all unique
                      bodyParts = []; 
                      // Without deep diving into routine exercises, we just don't display body parts here or we could just skip it since routine card will do it.
                    } else {
                      routineName = 'Routine deleted';
                    }
                  }

                  return ReorderableDelayedDragStartListener(
                    key: _dayKeys[index],
                    index: index,
                    child: CycleDayCard(
                      index: index,
                      day: day,
                      dayNumber: index + 1,
                      routineName: routineName,
                      bodyParts: bodyParts,
                      onEdit: () => _editDayLabel(index),
                      onDelete: () => _deleteDay(index),
                      onAssignRoutine: () => _assignRoutine(index),
                    ),
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  HapticFeedback.lightImpact();
                  _hasFiredDragHaptic = false;
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = _days.removeAt(oldIndex);
                    final key = _dayKeys.removeAt(oldIndex);
                    _days.insert(newIndex, item);
                    _dayKeys.insert(newIndex, key);
                    for (int i = 0; i < _days.length; i++) {
                      _days[i] = _days[i].copyWith(dayIndex: i);
                    }
                  });
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _addWorkoutDay,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.amber, style: BorderStyle.solid), // No dashed natively
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('+ Workout day', style: TextStyle(color: AppTheme.amber)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _addRestDay,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.txt3, style: BorderStyle.solid),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('+ Rest day', style: TextStyle(color: AppTheme.txt2)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_days.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cycle preview', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.txt1)),
                      const SizedBox(height: 12),
                      CycleProgressStrip(
                        days: _days,
                        currentDayIndex: 0,
                        completedDayIndices: const {},
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
