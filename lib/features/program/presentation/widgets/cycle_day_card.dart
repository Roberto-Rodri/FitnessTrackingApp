import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../workout/presentation/widgets/body_part_tag.dart';
import '../../domain/entities/program_day.dart';

class CycleDayCard extends StatelessWidget {
  final ProgramDay day;
  final int dayNumber;
  final String? routineName;
  final List<String>? bodyParts;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onAssignRoutine;
  final int index;

  const CycleDayCard({
    super.key,
    required this.day,
    required this.dayNumber,
    this.routineName,
    this.bodyParts,
    required this.onEdit,
    required this.onDelete,
    this.onAssignRoutine,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    if (day.label.toLowerCase() == 'rest') {
      return _buildRestDay();
    } else {
      return _buildWorkoutDay();
    }
  }

  Widget _buildWorkoutDay() {
    final hasRoutine = routineName != null;
    final primaryBodyPart = bodyParts?.isNotEmpty == true ? bodyParts!.first : 'default';
    final colors = hasRoutine ? BodyPartTag.getColors(primaryBodyPart) : (AppTheme.bg3, AppTheme.amber);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.bg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.bg3),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: hasRoutine ? onEdit : onAssignRoutine,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Drag handle
                ReorderableDragStartListener(
                  index: index,
                  child: const Column(
                    children: [
                      Icon(Icons.keyboard_arrow_up, size: 16, color: AppTheme.txt3),
                      Icon(Icons.drag_indicator, size: 16, color: AppTheme.txt3),
                      Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.txt3),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                
                // Day badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.$1,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    day.label.isNotEmpty ? day.label[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: colors.$2,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day $dayNumber · ${day.label}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.txt0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (hasRoutine)
                        Row(
                          children: [
                            Text(
                              routineName!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.txt1,
                              ),
                            ),
                            if (bodyParts != null && bodyParts!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: bodyParts!.map((bp) => Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: BodyPartTag(bodyPart: bp),
                                    )).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        )
                      else
                        const Text(
                          'Tap to assign routine',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppTheme.txt2,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Actions
                if (hasRoutine) ...[
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    color: AppTheme.txt2,
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.bg3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(38, 38),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: AppTheme.error,
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.bg3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(38, 38),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRestDay() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.bg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.bg3, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const Column(
                children: [
                  Icon(Icons.keyboard_arrow_up, size: 16, color: AppTheme.txt3),
                  Icon(Icons.drag_indicator, size: 16, color: AppTheme.txt3),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.txt3),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppTheme.bg3,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text(
                'R',
                style: TextStyle(
                  color: AppTheme.txt3,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            Expanded(
              child: Text(
                'Day $dayNumber · Rest',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.txt2,
                ),
              ),
            ),
            
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 18),
              color: AppTheme.error,
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.bg3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(38, 38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
