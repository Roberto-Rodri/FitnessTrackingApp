import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/user_profile.dart';
import '../controllers/profile_providers.dart';
import '../widgets/name_prompt_dialog.dart';

class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userProfileAsync = ref.watch(userProfileControllerProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        centerTitle: true,
      ),
      body: userProfileAsync.when(
        data: (profile) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name Section
                Text(
                  'NAME',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.txt2,
                    letterSpacing: 0.06,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(profile.name ?? 'Not set', style: theme.textTheme.titleMedium),
                  trailing: Icon(Icons.edit, color: theme.colorScheme.primary),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const NamePromptDialog(),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Training Phase Section
                Text(
                  'TRAINING PHASE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.txt2,
                    letterSpacing: 0.06,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPhaseOption(
                  context,
                  ref,
                  label: 'Gaining',
                  description: 'Caloric surplus for muscle growth.',
                  phase: TrainingPhase.gaining,
                  currentPhase: profile.phase,
                ),
                const SizedBox(height: 12),
                _buildPhaseOption(
                  context,
                  ref,
                  label: 'Cutting',
                  description: 'Caloric deficit for fat loss.',
                  phase: TrainingPhase.cutting,
                  currentPhase: profile.phase,
                ),
                const SizedBox(height: 12),
                _buildPhaseOption(
                  context,
                  ref,
                  label: 'Maintaining',
                  description: 'Maintenance calories for body recomposition.',
                  phase: TrainingPhase.maintaining,
                  currentPhase: profile.phase,
                ),
                const SizedBox(height: 12),
                _buildPhaseOption(
                  context,
                  ref,
                  label: 'None',
                  description: 'No specific phase.',
                  phase: TrainingPhase.none,
                  currentPhase: profile.phase,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildPhaseOption(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required String description,
    required TrainingPhase phase,
    required TrainingPhase currentPhase,
  }) {
    final theme = Theme.of(context);
    final isActive = phase == currentPhase;

    return InkWell(
      onTap: () async {
        HapticFeedback.mediumImpact();
        await ref.read(userProfileControllerProvider.notifier).saveTrainingPhase(phase);
        if (!context.mounted) return;
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? theme.colorScheme.primary : AppTheme.bg3,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isActive ? theme.colorScheme.primary : AppTheme.txt0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.txt2,
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              Icon(Icons.check_circle, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
