import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../controllers/body_weight_providers.dart';

class LogWeightSheet extends ConsumerStatefulWidget {
  const LogWeightSheet({super.key});

  @override
  ConsumerState<LogWeightSheet> createState() => _LogWeightSheetState();
}

class _LogWeightSheetState extends ConsumerState<LogWeightSheet> {
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _muscleMassController = TextEditingController();
  final _waistController = TextEditingController();
  final _chestController = TextEditingController();
  final _armsController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    _waistController.dispose();
    _chestController.dispose();
    _armsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _weightController.text.trim();
    if (text.isEmpty) return;

    final weight = double.tryParse(text);
    if (weight == null || weight <= 0) return;

    setState(() => _isSaving = true);
    
    await ref.read(bodyWeightLogsControllerProvider.notifier).addLog(
      weight,
      bodyFatPercentage: double.tryParse(_bodyFatController.text.trim()),
      muscleMass: double.tryParse(_muscleMassController.text.trim()),
      waist: double.tryParse(_waistController.text.trim()),
      chest: double.tryParse(_chestController.text.trim()),
      arms: double.tryParse(_armsController.text.trim()),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );
    
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Widget _buildOptionalField(String label, String suffix, TextEditingController controller) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: AppTheme.monoLarge(color: AppTheme.txt1).copyWith(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt3),
          filled: true,
          fillColor: AppTheme.bg2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.amber, width: 2),
          ),
          suffixText: suffix,
          suffixStyle: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.bg1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Log Metrics',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.txt0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: AppTheme.monoLarge(color: AppTheme.txt1).copyWith(fontSize: 24),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0.0',
                hintStyle: AppTheme.monoLarge(color: AppTheme.txt3).copyWith(fontSize: 24),
                filled: true,
                fillColor: AppTheme.bg2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.amber, width: 2),
                ),
                suffixText: 'kg', // Assuming kg, can be made dynamic later
                suffixStyle: theme.textTheme.bodyLarge?.copyWith(color: AppTheme.txt2),
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  'Add more metrics (optional)',
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.amber),
                ),
                iconColor: AppTheme.amber,
                collapsedIconColor: AppTheme.amber,
                tilePadding: EdgeInsets.zero,
                children: [
                  _buildOptionalField('Body Fat', '%', _bodyFatController),
                  _buildOptionalField('Muscle Mass', 'kg', _muscleMassController),
                  _buildOptionalField('Waist', 'cm', _waistController),
                  _buildOptionalField('Chest', 'cm', _chestController),
                  _buildOptionalField('Arms', 'cm', _armsController),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt1),
                    decoration: InputDecoration(
                      hintText: 'Notes',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt3),
                      filled: true,
                      fillColor: AppTheme.bg2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.amber, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.amber,
                foregroundColor: AppTheme.bg0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.bg0),
                    )
                  : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

