import 'dart:async';
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

    // Outer flame: #E8A83E
    final Paint outerFlame = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFE8A83E);
    
    Path outerFlamePath = Path()
      ..moveTo(100, 20)
      ..cubicTo(100, 20, 128, 52, 128, 80)
      ..cubicTo(128, 96, 118, 106, 108, 110)
      ..cubicTo(116, 98, 114, 84, 106, 76)
      ..cubicTo(106, 76, 110, 94, 100, 100)
      ..cubicTo(90, 94, 94, 76, 94, 76)
      ..cubicTo(86, 84, 84, 98, 92, 110)
      ..cubicTo(82, 106, 72, 96, 72, 80)
      ..cubicTo(72, 52, 100, 20, 100, 20)
      ..close();
    canvas.drawPath(outerFlamePath, outerFlame);

    // Inner flame: #F5C96A opacity 0.9 (0xE5F5C96A)
    final Paint innerFlame = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xE5F5C96A);
    
    Path innerFlamePath = Path()
      ..moveTo(100, 48)
      ..cubicTo(100, 48, 116, 66, 116, 82)
      ..cubicTo(116, 92, 110, 100, 104, 104)
      ..cubicTo(108, 96, 106, 86, 100, 80)
      ..cubicTo(94, 86, 92, 96, 96, 104)
      ..cubicTo(90, 100, 84, 92, 84, 82)
      ..cubicTo(84, 66, 100, 48, 100, 48)
      ..close();
    canvas.drawPath(innerFlamePath, innerFlame);

    // Flame tip highlight: #FFF5D6 opacity 0.6 (0x99FFF5D6)
    final Paint highlight = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0x99FFF5D6);
    
    // ellipse cx=100 cy=54 rx=4 ry=8
    canvas.drawOval(const Rect.fromLTRB(96, 46, 104, 62), highlight);

    // Barbell
    final Paint barbellE8A83E = Paint()..color = const Color(0xFFE8A83E);
    final Paint barbellC8901A = Paint()..color = const Color(0xFFC8901A);
    final Paint barbellB07B22 = Paint()..color = const Color(0xFFB07B22);
    final Paint barbellHalfE8A83E = Paint()..color = const Color(0x7FE8A83E); // opacity 0.5

    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(2, 110, 12, 40), const Radius.circular(4)), barbellE8A83E);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(12, 116, 22, 28), const Radius.circular(5)), barbellC8901A);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(24, 126, 152, 8), const Radius.circular(4)), barbellB07B22);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(24, 126, 152, 3), const Radius.circular(1.5)), barbellHalfE8A83E);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(166, 116, 22, 28), const Radius.circular(5)), barbellC8901A);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(186, 110, 12, 40), const Radius.circular(4)), barbellE8A83E);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
