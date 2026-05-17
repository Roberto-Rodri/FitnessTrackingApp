import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/pressable_card.dart';
import '../../../../core/routing/router.dart';
import '../controllers/body_weight_providers.dart';
import 'log_weight_sheet.dart';

class BodyWeightCard extends ConsumerWidget {
  const BodyWeightCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logsAsync = ref.watch(bodyWeightLogsNotifierProvider);

    return PressableCard(
      onTap: () {
        context.pushNamed(RouteNames.bodyWeightHistory);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bg1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.bg3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CURRENT WEIGHT',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.txt2,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: AppTheme.amber),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const LogWeightSheet(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            logsAsync.when(
              data: (logs) {
                if (logs.isEmpty) {
                  return Text(
                    '--',
                    style: AppTheme.monoLarge(color: AppTheme.txt0).copyWith(fontSize: 32),
                  );
                }
                final latestWeight = logs.first.weight;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      latestWeight.toStringAsFixed(1),
                      style: AppTheme.monoLarge(color: AppTheme.txt0).copyWith(fontSize: 32),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'kg',
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt2),
                    ),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error loading weight'),
            ),
          ],
        ),
      ),
    );
  }
}
