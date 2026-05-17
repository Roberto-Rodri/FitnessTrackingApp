import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme.dart';

class ErrorCard extends StatefulWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;

  const ErrorCard({
    super.key,
    this.title = 'Something went wrong',
    this.message,
    this.onRetry,
  });

  @override
  State<ErrorCard> createState() => _ErrorCardState();
}

class _ErrorCardState extends State<ErrorCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HapticFeedback.heavyImpact();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coral = theme.colorScheme.tertiary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: coral.withValues(alpha: 0.27)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.coralDim.withValues(alpha: 0.53),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: coral.withValues(alpha: 0.27)),
                ),
                child: Icon(Icons.warning_rounded, color: coral, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (widget.message != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.message!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: AppTheme.txt2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (widget.onRetry != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                onPressed: widget.onRetry,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: coral.withValues(alpha: 0.33)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(Icons.refresh, color: coral, size: 18),
                label: Text(
                  'Try again',
                  style: TextStyle(
                    color: coral,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ErrorScreen extends StatefulWidget {
  final String headline;
  final String subtitle;
  final VoidCallback? onRetry;

  const ErrorScreen({
    super.key,
    this.headline = 'Something went wrong',
    this.subtitle = 'Please try again later.',
    this.onRetry,
  });

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HapticFeedback.heavyImpact();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coral = theme.colorScheme.tertiary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.coralDim.withValues(alpha: 0.40),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: coral.withValues(alpha: 0.27)),
            ),
            child: Icon(Icons.warning_rounded, color: coral, size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            widget.headline,
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
              widget.subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                color: AppTheme.txt2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (widget.onRetry != null) ...[
            const SizedBox(height: 24),
            TextButton(
              onPressed: widget.onRetry,
              style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHigh,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: BorderSide(color: coral.withValues(alpha: 0.27)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              child: Text(
                'Try again',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: coral,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
