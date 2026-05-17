import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class CarryForwardNotesCard extends StatelessWidget {
  final String notes;

  const CarryForwardNotesCard({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bg1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.bg3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PREVIOUS NOTES',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppTheme.txt2,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notes,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.txt1,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
