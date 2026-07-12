import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/user_profile.dart';
import '../controllers/profile_providers.dart';
import '../widgets/name_prompt_dialog.dart';
import '../../../../core/routing/router.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/backup_providers.dart';
import 'package:share_plus/share_plus.dart';

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
      body: Stack(
        children: [
          userProfileAsync.when(
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
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Body Weight Logs', style: theme.textTheme.titleMedium),
                  trailing: Icon(Icons.chevron_right, color: theme.colorScheme.primary),
                  onTap: () {
                    context.pushNamed(RouteNames.bodyWeightHistory);
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Progress Report', style: theme.textTheme.titleMedium),
                  trailing: Icon(Icons.analytics_outlined, color: theme.colorScheme.primary),
                  onTap: () {
                    context.pushNamed(RouteNames.progressReport);
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
                const SizedBox(height: 32),

                // Data Management Section
                Text(
                  'DATA',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.txt2,
                    letterSpacing: 0.06,
                  ),
                ),
                const SizedBox(height: 16),
                _buildExportButton(context, ref),
                const SizedBox(height: 12),
                _buildImportButton(context, ref),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      if (ref.watch(backupControllerProvider).isLoading)
        Positioned.fill(
          child: Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ],
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

  Widget _buildExportButton(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        try {
          final path = await ref.read(backupControllerProvider.notifier).exportDatabase();
          debugPrint('EXPORTED BACKUP TO: $path');
          if (context.mounted) {
            final box = context.findRenderObject() as RenderBox?;
            // ignore: deprecated_member_use
            await Share.shareXFiles(
              [XFile(path)],
              text: 'IronLog Backup',
              sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export ready'),
                  backgroundColor: AppTheme.green,
                ),
              );
            }
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Export failed: $e'),
                backgroundColor: AppTheme.coral,
              ),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bg3,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.upload, color: AppTheme.txt1),
            const SizedBox(width: 16),
            Text(
              'Export Data',
              style: AppTheme.monoLarge(color: AppTheme.txt1).copyWith(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportButton(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        final confirm = await _showWarningDialog(context, ref);
        if (confirm == true && context.mounted) {
          // Open paste dialog as fallback for missing file_picker
          final controller = TextEditingController();
          final jsonString = await showDialog<String>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppTheme.bg1,
              title: const Text('Paste JSON Backup', style: TextStyle(color: AppTheme.txt1)),
              content: TextField(
                controller: controller,
                maxLines: 5,
                style: const TextStyle(color: AppTheme.txt1),
                decoration: InputDecoration(
                  hintText: '{"version": 8, ...}',
                  hintStyle: const TextStyle(color: AppTheme.txt2),
                  filled: true,
                  fillColor: AppTheme.bg0,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: AppTheme.txt2)),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.coral, foregroundColor: AppTheme.txt1),
                  onPressed: () => Navigator.pop(ctx, controller.text),
                  child: const Text('Replace'),
                ),
              ],
            ),
          );

          if (jsonString != null && jsonString.isNotEmpty && context.mounted) {
            try {
              await ref.read(backupControllerProvider.notifier).importDatabase(jsonString);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Import successful!'),
                    backgroundColor: AppTheme.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Import failed: $e'),
                    backgroundColor: AppTheme.coral,
                  ),
                );
              }
            }
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Import requires file_picker plugin'),
                backgroundColor: AppTheme.amber,
              ),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bg3,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.download, color: AppTheme.coral),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Import Data',
                  style: AppTheme.monoLarge(color: AppTheme.coral).copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  'Replace all current data',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.coral),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showWarningDialog(BuildContext context, WidgetRef ref) async {
    final statsAsync = ref.read(backupStatsProvider);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bg1,
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.coralDim,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: AppTheme.coral, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              'Replace all data?',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(color: AppTheme.txt1),
            ),
            const SizedBox(height: 8),
            Text(
              'This will permanently delete all your current workouts, routines, and exercises. This cannot be undone.',
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: AppTheme.txt2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bg3,
                borderRadius: BorderRadius.circular(8),
              ),
              child: statsAsync.when(
                data: (stats) => Text(
                  'Current data: ${stats.workouts} workouts · ${stats.routines} routines · ${stats.exercises} exercises',
                  style: AppTheme.monoSmall(color: AppTheme.txt1),
                  textAlign: TextAlign.center,
                ),
                loading: () => const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, __) => const Text('Could not load stats', style: TextStyle(color: AppTheme.coral)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.txt2)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.coral, foregroundColor: AppTheme.txt1),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Replace data'),
          ),
        ],
      ),
    );
  }
}
