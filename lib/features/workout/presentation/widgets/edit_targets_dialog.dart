import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme.dart';

class EditTargetsDialog extends StatefulWidget {
  final int initialSets;
  final String initialReps;
  final int initialRestSeconds;

  const EditTargetsDialog({
    super.key,
    required this.initialSets,
    required this.initialReps,
    required this.initialRestSeconds,
  });

  @override
  State<EditTargetsDialog> createState() => _EditTargetsDialogState();
}

class _EditTargetsDialogState extends State<EditTargetsDialog> {
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _restController;

  @override
  void initState() {
    super.initState();
    _setsController = TextEditingController(text: widget.initialSets.toString());
    _repsController = TextEditingController(text: widget.initialReps);
    _restController = TextEditingController(text: widget.initialRestSeconds.toString());
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _restController.dispose();
    super.dispose();
  }

  void _save() {
    final setsText = _setsController.text.trim();
    final repsText = _repsController.text.trim();
    final restText = _restController.text.trim();

    final sets = int.tryParse(setsText);
    if (sets == null || sets <= 0) return;

    if (repsText.isEmpty) return;

    final restSeconds = int.tryParse(restText);
    if (restSeconds == null || restSeconds <= 0) return;

    HapticFeedback.mediumImpact();
    Navigator.of(context).pop({'sets': sets, 'reps': repsText, 'restSeconds': restSeconds});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final setsText = _setsController.text.isEmpty ? '?' : _setsController.text;
    final repsText = _repsController.text.isEmpty ? '?' : _repsController.text;

    return Dialog(
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 32.0, bottom: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit Targets',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$setsText sets of $repsText',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.amber),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            _buildInputField(theme, 'Sets', _setsController, TextInputType.number),
            const SizedBox(height: 16),
            _buildInputField(theme, 'Reps', _repsController, TextInputType.text),
            const SizedBox(height: 16),
            _buildInputField(theme, 'Rest (s)', _restController, TextInputType.number),
            
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
    );
  }

  Widget _buildInputField(ThemeData theme, String label, TextEditingController controller, TextInputType type) {
    return TextField(
      controller: controller,
      keyboardType: type,
      onChanged: (_) => setState(() {}),
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
    );
  }
}

Future<Map<String, dynamic>?> showEditTargetsDialog(BuildContext context, int initialSets, String initialReps, int initialRestSeconds) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => EditTargetsDialog(
      initialSets: initialSets,
      initialReps: initialReps,
      initialRestSeconds: initialRestSeconds,
    ),
  );
}
