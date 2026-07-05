import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../controllers/workout_providers.dart';

class SessionNotesSheet extends ConsumerStatefulWidget {
  const SessionNotesSheet({super.key});

  @override
  ConsumerState<SessionNotesSheet> createState() => _SessionNotesSheetState();
}

class _SessionNotesSheetState extends ConsumerState<SessionNotesSheet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final state = ref.read(workoutSessionControllerProvider).value;
    _controller = TextEditingController(text: state?.notes ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessionState = ref.watch(workoutSessionControllerProvider).value;
    final previousNotes = sessionState?.previousSessionNotes;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Session Notes',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.txt0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (previousNotes != null && previousNotes.isNotEmpty) ...[
            Text(
              'PREVIOUS NOTES',
              style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.txt2, letterSpacing: 0.06),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bg2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                previousNotes,
                style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt2),
              ),
            ),
            const SizedBox(height: 24),
          ],
          TextField(
            controller: _controller,
            maxLines: 4,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt1),
            decoration: InputDecoration(
              hintText: 'How did this session feel?',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt3),
              filled: true,
              fillColor: AppTheme.bg2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.bg3),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.bg3),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.amber, width: 2),
              ),
            ),
            onChanged: (text) {
              ref.read(workoutSessionControllerProvider.notifier).updateNotes(text);
            },
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.amber,
              foregroundColor: AppTheme.bg0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
