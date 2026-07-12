import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exercise.dart';
import '../controllers/workout_providers.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/machine.dart';
import '../controllers/machine_providers.dart';
import 'machine_picker_sheet.dart';

class ExerciseFormDialog extends ConsumerStatefulWidget {
  final Exercise? existingExercise;

  const ExerciseFormDialog({super.key, this.existingExercise});

  @override
  ConsumerState<ExerciseFormDialog> createState() => _ExerciseFormDialogState();
}

class _ExerciseFormDialogState extends ConsumerState<ExerciseFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _bodyPartController;
  final _formKey = GlobalKey<FormState>();
  String _weightUnit = 'kg';
  Machine? _selectedMachine;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingExercise?.name ?? '');
    _bodyPartController = TextEditingController(text: widget.existingExercise?.bodyPart ?? '');
    _weightUnit = widget.existingExercise?.weightUnit ?? 'kg';
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.existingExercise?.machineId != null && mounted) {
        final machines = await ref.read(machinesProvider.future);
        if (mounted) {
          setState(() {
            _selectedMachine = machines.cast<Machine?>().firstWhere(
              (m) => m?.id == widget.existingExercise!.machineId, 
              orElse: () => null
            );
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bodyPartController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: AppTheme.coral, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.bg2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.coral, width: 1),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final bodyPart = _bodyPartController.text.trim();

    if (name.isEmpty) {
      _showErrorSnackBar('Exercise name is required.');
      return;
    }

    if (bodyPart.isEmpty) {
      _showErrorSnackBar('Please choose a body part.');
      return;
    }

    final repository = ref.read(workoutRepositoryProvider);
    final exists = await repository.exerciseNameExists(name, excludeId: widget.existingExercise?.id);

    if (exists) {
      _showErrorSnackBar('An exercise with this name already exists.');
      return;
    }

    if (!mounted) return;
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop({
      'name': name, 
      'bodyPart': bodyPart, 
      'weightUnit': _weightUnit,
      'machineId': _selectedMachine?.id,
    });
  }

  @override
  Widget build(BuildContext context) {
    final bodyPartsAsync = ref.watch(bodyPartsProvider);
    final allExercisesAsync = ref.watch(allExercisesProvider);
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 32.0, bottom: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existingExercise == null ? 'New Exercise' : 'Edit Exercise',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),



              allExercisesAsync.when(
                data: (exercisesList) => Autocomplete<String>(
                  initialValue: TextEditingValue(text: widget.existingExercise?.name ?? ''),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    return exercisesList
                        .map((e) => e.name)
                        .where((name) => name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (String selection) {
                    _nameController.text = selection;
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                    textEditingController.addListener(() {
                      _nameController.text = textEditingController.text;
                    });
                    return _buildTextFormField(
                      theme,
                      controller: textEditingController,
                      focusNode: focusNode,
                      label: 'Exercise Name',
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Text('Error: $err'),
              ),
              
              const SizedBox(height: 16),
              
              bodyPartsAsync.when(
                data: (bodyPartsList) => Autocomplete<String>(
                  initialValue: TextEditingValue(text: widget.existingExercise?.bodyPart ?? ''),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    return bodyPartsList.where((String option) {
                      return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    _bodyPartController.text = selection;
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                    textEditingController.addListener(() {
                      _bodyPartController.text = textEditingController.text;
                    });
                    return _buildTextFormField(
                      theme,
                      controller: textEditingController,
                      focusNode: focusNode,
                      label: 'Body Part',
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Text('Error: $err'),
              ),
              const SizedBox(height: 24),
              
              Text('Machine (Optional)', style: theme.textTheme.labelMedium?.copyWith(color: AppTheme.txt2)),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final machine = await showMachinePickerSheet(context);
                  if (machine != null && mounted) {
                    setState(() => _selectedMachine = machine);
                  }
                },
                child: Ink(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedMachine != null ? Icons.precision_manufacturing : Icons.add_circle_outline,
                        color: _selectedMachine != null ? theme.colorScheme.primary : AppTheme.txt2,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedMachine?.name ?? 'No machine assigned',
                          style: TextStyle(
                            color: _selectedMachine != null ? theme.colorScheme.onSurface : AppTheme.txt2,
                            fontWeight: _selectedMachine != null ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (_selectedMachine != null)
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => setState(() => _selectedMachine = null),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      else
                        const Icon(Icons.chevron_right, color: AppTheme.txt2),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Text('Weight Unit', style: theme.textTheme.labelMedium?.copyWith(color: AppTheme.txt2)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                  selectedForegroundColor: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
                segments: const [
                  ButtonSegment(value: 'kg', label: Text('kg')),
                  ButtonSegment(value: 'lbs', label: Text('lbs')),
                  ButtonSegment(value: 'plates', label: Text('Plates')),
                  ButtonSegment(value: 'custom', label: Text('Custom')),
                ],
                selected: {_weightUnit},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _weightUnit = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _save,
                      child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    ThemeData theme, {
    required TextEditingController controller,
    required String label,
    FocusNode? focusNode,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}

Future<Map<String, dynamic>?> showExerciseFormDialog(BuildContext context, {Exercise? existingExercise}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => ExerciseFormDialog(existingExercise: existingExercise),
  );
}
