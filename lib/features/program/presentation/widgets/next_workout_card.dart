import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../workout/presentation/widgets/body_part_tag.dart';

import '../../../../core/widgets/pressable_card.dart';

class NextWorkoutCard extends StatelessWidget {
  final String programName;
  final int currentDay;
  final int totalDays;
  final String routineName;
  final List<String> bodyParts;
  final int exerciseCount;
  final VoidCallback? onStart;
  final VoidCallback onDifferentDay;

  const NextWorkoutCard({
    super.key,
    required this.programName,
    required this.currentDay,
    required this.totalDays,
    required this.routineName,
    required this.bodyParts,
    required this.exerciseCount,
    this.onStart,
    required this.onDifferentDay,
  });

  @override
  Widget build(BuildContext context) {
    return PressableCard(
      onTap: onStart,
      child: Container(
        decoration: BoxDecoration(
        color: AppTheme.bg1,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.bg3),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$programName  Day $currentDay of $totalDays',
              style: const TextStyle(
                color: AppTheme.amber,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            routineName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.txt0,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...bodyParts.map((bp) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: BodyPartTag(bodyPart: bp),
              )),
              const SizedBox(width: 4),
              Text(
                '$exerciseCount ex',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.txt2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.amber,
                foregroundColor: AppTheme.bg0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 24),
              label: const Text(
                'Start workout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: onDifferentDay,
              child: const Text(
                'Do a different day ›',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.txt2,
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
