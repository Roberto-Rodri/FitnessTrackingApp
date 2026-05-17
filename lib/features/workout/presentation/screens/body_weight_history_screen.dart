import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/theme.dart';
import '../controllers/body_weight_providers.dart';

class BodyWeightHistoryScreen extends ConsumerWidget {
  const BodyWeightHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logsAsync = ref.watch(bodyWeightLogsNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg0,
      appBar: AppBar(
        backgroundColor: AppTheme.bg0,
        elevation: 0,
        title: Text(
          'BODY WEIGHT HISTORY',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppTheme.txt1,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.txt1),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return Center(
              child: Text(
                'No logs yet.',
                style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt2),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Dismissible(
                key: Key(log.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: theme.colorScheme.error,
                  child: const Icon(Icons.delete, color: AppTheme.bg0),
                ),
                onDismissed: (_) {
                  ref.read(bodyWeightLogsNotifierProvider.notifier).deleteLog(log.id);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppTheme.bg3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMM d, yyyy').format(log.date),
                        style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.txt2),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            log.weight.toStringAsFixed(1),
                            style: AppTheme.monoLarge(color: AppTheme.txt1).copyWith(fontSize: 20),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'kg',
                            style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.txt3),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
