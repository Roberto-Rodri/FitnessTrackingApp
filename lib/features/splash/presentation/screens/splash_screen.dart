import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/routing/router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _textController;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    // 1. Fade in icon
    await _iconController.forward();
    
    // 2. Wait 200ms
    await Future.delayed(const Duration(milliseconds: 200));
    
    // 3. Fade in text
    await _textController.forward();
    
    // 4. Wait 600ms
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Navigate to home
    if (mounted) {
      context.goNamed(RouteNames.home);
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg0, // #161412
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _iconController,
                curve: Curves.easeOut,
              ),
              child: SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: _IronLogMarkPainter(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _textController,
                curve: Curves.easeOut,
              ),
              child: const Text(
                'IronLog',
                style: TextStyle(
                  fontFamily: 'DMSans', // Standard font
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.txt0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IronLogMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Original SVG viewbox is 0 0 200 200
    final scale = size.width / 200;
    canvas.scale(scale, scale);

    // 1. Radial background
    final Paint bgPaint = Paint()
      ..shader = ui.Gradient.radial(
        const Offset(100, 100),
        140,
        [const Color(0xFF241F1A), const Color(0xFF161412)],
        [0.0, 1.0],
      );
    // Clip to rounded rect if needed, but the splash background is already solid. We will just draw a 200x200 rect
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 200, 200), const Radius.circular(44)),
      bgPaint,
    );

    // 2. Area fill
    final Paint areaFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFE8A83E).withValues(alpha: 0.14);

    final Path areaPath = Path()
      ..moveTo(34, 158)
      ..lineTo(34, 148)
      ..lineTo(74, 110)
      ..lineTo(112, 124)
      ..lineTo(166, 46)
      ..lineTo(166, 158)
      ..close();
    canvas.drawPath(areaPath, areaFillPaint);

    // 3. Trend line
    final Paint trendLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFFE8A83E)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
      
    final Path trendPath = Path()
      ..moveTo(34, 148)
      ..lineTo(74, 110)
      ..lineTo(112, 124)
      ..lineTo(166, 46);
    canvas.drawPath(trendPath, trendLinePaint);

    // 4. Peak node outer ring
    final Paint outerNodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF161412);
    canvas.drawCircle(const Offset(166, 46), 15, outerNodePaint);

    // 5. Peak node inner core
    final Paint innerNodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFF5D6);
    canvas.drawCircle(const Offset(166, 46), 11, innerNodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
