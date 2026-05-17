import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

enum PRBadgeSize { sm, md, lg }

class PRBadge extends StatelessWidget {
  final PRBadgeSize size;
  final int? count; // If provided, shows "N PRs" instead of "PR"

  const PRBadge({super.key, this.size = PRBadgeSize.md, this.count});

  @override
  Widget build(BuildContext context) {
    double fontSize;
    EdgeInsets padding;
    double iconSize;

    switch (size) {
      case PRBadgeSize.sm:
        fontSize = 10;
        padding = const EdgeInsets.symmetric(vertical: 2, horizontal: 8);
        iconSize = 12;
        break;
      case PRBadgeSize.md:
        fontSize = 12;
        padding = const EdgeInsets.symmetric(vertical: 4, horizontal: 10);
        iconSize = 14;
        break;
      case PRBadgeSize.lg:
        fontSize = 13;
        padding = const EdgeInsets.symmetric(vertical: 5, horizontal: 12);
        iconSize = 15;
        break;
    }

    final String text = count == null 
      ? 'PR' 
      : count == 1 ? '1 PR' : '$count PRs';

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.amber.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.amber.withValues(alpha: 0.27)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events,
            color: AppTheme.amber,
            size: iconSize,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: AppTheme.amber,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
