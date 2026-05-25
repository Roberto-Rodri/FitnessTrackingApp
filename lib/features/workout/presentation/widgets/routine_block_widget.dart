import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../controllers/routine_editor_controller.dart';
import 'routine_exercise_tile.dart';

class RoutineBlockWidget extends StatelessWidget {
  final RoutineBlock block;
  final int blockIndex;
  final bool isLastBlock;
  final Function(int) onUnlink;
  final VoidCallback onLinkWithNext;
  final Function(int) onEditTargets;
  final Function(int) onDismissed;

  const RoutineBlockWidget({
    super.key,
    required this.block,
    required this.blockIndex,
    required this.isLastBlock,
    required this.onUnlink,
    required this.onLinkWithNext,
    required this.onEditTargets,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isGrouped = block.exercises.length > 1;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isGrouped)
          Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
            child: Text(
              _getGroupLabel(block.exercises.length),
              style: AppTheme.monoSmall(color: AppTheme.amber).copyWith(fontSize: 10),
            ),
          ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isGrouped)
                Container(
                  width: 3,
                  margin: const EdgeInsets.only(left: 4, right: 8, bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.amber,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: block.exercises.asMap().entries.map((entry) {
                    final ex = entry.value;
                    return Stack(
                      children: [
                        RoutineExerciseTile(
                          key: ValueKey('tile_${ex.exerciseId}'),
                          exercise: ex,
                          // Use blockIndex for ReorderableDragStartListener so the whole block drags
                          index: blockIndex,
                          onEditTargets: () => onEditTargets(ex.exerciseId),
                          onDismissed: () => onDismissed(ex.exerciseId),
                        ),
                        if (isGrouped)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: IconButton(
                              icon: const Icon(Icons.link_off, size: 20, color: AppTheme.txt2),
                              onPressed: () => onUnlink(ex.exerciseId),
                              tooltip: 'Unlink from group',
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (!isLastBlock) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          content,
          Center(
            child: Transform.translate(
              offset: const Offset(0, -6),
              child: InkWell(
                onTap: onLinkWithNext,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.amber.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.amber),
                  ),
                  child: const Icon(Icons.link, size: 16, color: AppTheme.amber),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      key: ValueKey('block_$blockIndex'),
      padding: const EdgeInsets.only(bottom: 8.0),
      child: content,
    );
  }

  String _getGroupLabel(int count) {
    if (count == 2) return 'SUPERSET';
    if (count == 3) return 'TRISET';
    return 'CIRCUIT';
  }
}
