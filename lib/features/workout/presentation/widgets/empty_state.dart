import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class EmptyState extends StatelessWidget {
  final Widget icon;
  final String headline;
  final String subtitle;
  final String? ctaLabel;
  final VoidCallback? onCtaTap;
  final bool dim;

  const EmptyState({
    super.key,
    required this.icon,
    required this.headline,
    required this.subtitle,
    this.ctaLabel,
    this.onCtaTap,
    this.dim = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(height: 20),
          Text(
            headline,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                color: AppTheme.txt2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (ctaLabel != null && onCtaTap != null) ...[
            const SizedBox(height: 24),
            TextButton(
              onPressed: onCtaTap,
              style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              child: Text(
                ctaLabel!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1000),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (dim) {
      content = Opacity(opacity: 0.7, child: content);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        );
      },
      child: content,
    );
  }
}
