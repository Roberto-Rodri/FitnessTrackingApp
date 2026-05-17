import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/exercise.dart';
import 'body_part_tag.dart';

class QuickSwapSheet extends StatelessWidget {
  final List<Exercise> alternatives;

  const QuickSwapSheet({
    super.key,
    required this.alternatives,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'QUICK SWAP',
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 11,
              color: AppTheme.txt3,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...alternatives.map((alt) => InkWell(
                onTap: () {
                  Navigator.pop(context, alt); // Return the selected alternative
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          alt.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      BodyPartTag(bodyPart: alt.bodyPart),
                    ],
                  ),
                ),
              )),
          Divider(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2), height: 32),
          InkWell(
            onTap: () {
              Navigator.pop(context, 'SHOW_MORE');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'More exercises...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.amber,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
