import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../controllers/workout_providers.dart';

class SessionNotesField extends ConsumerWidget {
  const SessionNotesField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sessionState = ref.watch(workoutSessionControllerProvider).value;

    if (sessionState == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SESSION NOTES',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppTheme.txt2,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            minLines: 3,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.newline,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt1),
            decoration: InputDecoration(
              hintText: 'How did the workout feel?',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt3),
              filled: true,
              fillColor: AppTheme.bg2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.bg3, width: 2),
              ),
            ),
            onChanged: (text) {
              ref.read(workoutSessionControllerProvider.notifier).updateNotes(text);
            },
          ),
        ],
      ),
    );
  }
}
