import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool isPlaying;

  const ConfettiOverlay({
    super.key,
    required this.child,
    this.isPlaying = false,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _controller.addListener(() {
      setState(() {
        for (var particle in _particles) {
          particle.update();
        }
      });
    });
    if (widget.isPlaying) {
      _startConfetti();
    }
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _startConfetti();
    }
  }

  void _startConfetti() {
    _particles.clear();
    for (int i = 0; i < 60; i++) {
      _particles.add(_ConfettiParticle(_random));
    }
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_controller.isAnimating)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(_particles, _controller.value),
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double rotation;
  double rotationSpeed;

  _ConfettiParticle(Random random)
      : x = random.nextDouble() * 400, // Approximate screen width, will scale
        y = -10 - random.nextDouble() * 200,
        vx = (random.nextDouble() - 0.5) * 4,
        vy = random.nextDouble() * 3 + 2,
        size = random.nextDouble() * 6 + 4,
        color = _colors[random.nextInt(_colors.length)],
        rotation = random.nextDouble() * pi * 2,
        rotationSpeed = (random.nextDouble() - 0.5) * 0.2;

  static const List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  void update() {
    x += vx;
    y += vy;
    rotation += rotationSpeed;
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double animationValue;

  _ConfettiPainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: 1.0 - animationValue)
        ..style = PaintingStyle.fill;
      
      canvas.save();
      // Adjust x to fit screen size proportion
      final actualX = (particle.x / 400) * size.width;
      canvas.translate(actualX, particle.y + (animationValue * 500));
      canvas.rotate(particle.rotation + (animationValue * particle.rotationSpeed * 100));
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size * 0.8), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
