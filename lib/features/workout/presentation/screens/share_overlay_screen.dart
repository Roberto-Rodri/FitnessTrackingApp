import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme.dart';
import '../controllers/workout_providers.dart';

class ShareOverlayScreen extends ConsumerWidget {
  final int sessionId;

  const ShareOverlayScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(workoutSummaryProvider(sessionId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.bg0,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text('Share Workout', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
        data: (summary) {
          return SafeArea(
            child: Column(
              children: [
                const Spacer(),
                
                // AspectRatio 9:16 for Instagram Story
                Center(
                  child: AspectRatio(
                    aspectRatio: 1080 / 1920,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: RepaintBoundary(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.bg1,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppTheme.bg3),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 32),
                              const Icon(Icons.fitness_center, color: AppTheme.amber, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                'IRONLOG',
                                textAlign: TextAlign.center,
                                style: AppTheme.monoLarge(color: AppTheme.txt1).copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              const Spacer(),
                              
                              Text(
                                summary.session.routineNameSnapshot,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.txt1,
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _ShareStatBox(label: 'VOLUME', value: '${summary.totalVolume.toStringAsFixed(0)}kg'),
                                  const SizedBox(width: 16),
                                  _ShareStatBox(label: 'SETS', value: '${summary.totalSets}'),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (summary.totalPRs > 0)
                                _ShareStatBox(label: 'NEW PRs', value: '${summary.totalPRs}', color: AppTheme.amber),
                                
                              const Spacer(),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const Spacer(),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: FilledButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text(
                      'Share to Instagram',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.amber,
                      foregroundColor: AppTheme.bg0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      // TODO: Implement actual export action when plugin is added
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Export requires plugin')),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ShareStatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ShareStatBox({required this.label, required this.value, this.color = AppTheme.bg3});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: AppTheme.monoSmall(color: color == AppTheme.bg3 ? AppTheme.txt2 : AppTheme.bg0)),
          const SizedBox(height: 4),
          Text(value, style: AppTheme.monoLarge(color: color == AppTheme.bg3 ? AppTheme.txt1 : AppTheme.bg0)),
        ],
      ),
    );
  }
}
