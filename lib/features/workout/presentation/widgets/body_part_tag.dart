import 'package:flutter/material.dart';

class BodyPartTag extends StatelessWidget {
  final String bodyPart;
  const BodyPartTag({super.key, required this.bodyPart});
  
  @override
  Widget build(BuildContext context) {
    final colors = getColors(bodyPart);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        bodyPart,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: colors.$2,
        ),
      ),
    );
  }

  static (Color background, Color text) getColors(String bodyPart) {
    switch (bodyPart.toLowerCase()) {
      case 'chest':
        return (const Color(0xFFE8A83E).withValues(alpha: 0.18), const Color(0xFFE8A83E));
      case 'back':
        return (const Color(0xFF1A3A2E), const Color(0xFF5DCAA5));
      case 'legs':
        return (const Color(0xFF2E1A3A), const Color(0xFFB488D0));
      case 'shoulders':
        return (const Color(0xFF3A2E1A), const Color(0xFFD4A84E));
      case 'arms':
        return (const Color(0xFF1A2E3A), const Color(0xFF6AADDC));
      case 'core':
        return (const Color(0xFF3A1A2E), const Color(0xFFD06A8A));
      default:
        return (const Color(0xFF3D352C), const Color(0xFF8A8078));
    }
  }
}
