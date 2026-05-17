import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class TemplateConfig {
  final String name;
  final String description;
  final String defaultName;
  final List<(String label, bool isRest)> days;

  const TemplateConfig({
    required this.name,
    required this.description,
    required this.defaultName,
    required this.days,
  });
}

final templates = [
  const TemplateConfig(
    name: 'Push / Pull / Legs',
    description: 'Classic 6-day split · No rest days',
    defaultName: 'PPL Program',
    days: [
      ('Push A', false), ('Pull A', false), ('Legs A', false),
      ('Push B', false), ('Pull B', false), ('Legs B', false),
    ],
  ),
  const TemplateConfig(
    name: 'Upper / Lower',
    description: '5-day cycle · 2 rest days',
    defaultName: 'Upper Lower Program',
    days: [
      ('Upper A', false), ('Lower A', false), ('Rest', true),
      ('Upper B', false), ('Rest', true),
    ],
  ),
  const TemplateConfig(
    name: 'Full Body 3×',
    description: '5-day cycle · 2 rest days',
    defaultName: 'Full Body Program',
    days: [
      ('Full Body A', false), ('Rest', true), ('Full Body B', false),
      ('Rest', true), ('Full Body C', false),
    ],
  ),
];

class TemplatePicker extends StatelessWidget {
  final Function(TemplateConfig) onTemplateSelected;
  final VoidCallback onStartFromScratch;

  const TemplatePicker({
    super.key,
    required this.onTemplateSelected,
    required this.onStartFromScratch,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final template in templates)
          _TemplateCard(
            template: template,
            onTap: () => onTemplateSelected(template),
          ),
        _StartFromScratchCard(onTap: onStartFromScratch),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final TemplateConfig template;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bg1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.bg3),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.txt0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  template.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.txt2,
                  ),
                ),
              ],
            ),
            Row(
              children: template.days.map((day) {
                if (day.$2) {
                  return Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.bg3, width: 1, style: BorderStyle.solid), 
                    ),
                  );
                } else {
                  return Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: const BoxDecoration(
                      color: AppTheme.amber,
                      shape: BoxShape.circle,
                    ),
                  );
                }
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartFromScratchCard extends StatelessWidget {
  final VoidCallback onTap;

  const _StartFromScratchCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bg1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.bg3),
        ),
        padding: const EdgeInsets.all(12),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 24, color: AppTheme.amber),
            SizedBox(height: 8),
            Text(
              'Start from scratch',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.txt0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              'Build your own cycle',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.txt2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
