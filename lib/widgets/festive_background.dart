import 'dart:math';

import 'package:flutter/material.dart';

class FestiveBackground extends StatefulWidget {
  final Widget child;

  const FestiveBackground({
    super.key,
    required this.child,
  });

  @override
  State<FestiveBackground> createState() => _FestiveBackgroundState();
}

class _FestiveBackgroundState extends State<FestiveBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final Random random = Random();

  late final List<SnowParticle> snow;
  late final List<LightParticle> lights;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    snow = List.generate(
      45,
          (index) => SnowParticle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 2 + random.nextDouble() * 5,
        speed: 0.15 + random.nextDouble() * 0.35,
        drift: random.nextDouble() * 2 - 1,
      ),
    );

    lights = List.generate(
      12,
          (index) => LightParticle(
        x: index / 11,
        color: index.isEven
            ? const Color(0xFFB7F34A)
            : const Color(0xFFFF3B30),
        phase: random.nextDouble(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF050706),
                    Color(0xFF101510),
                    Color(0xFF071009),
                  ],
                ),
              ),
            ),

            CustomPaint(
              painter: FestivePainter(
                progress: _controller.value,
                snow: snow,
                lights: lights,
              ),
            ),

            widget.child,
          ],
        );
      },
    );
  }
}

class SnowParticle {
  double x;
  double y;

  final double size;
  final double speed;
  final double drift;

  SnowParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.drift,
  });
}

class LightParticle {
  final double x;
  final Color color;
  final double phase;

  LightParticle({
    required this.x,
    required this.color,
    required this.phase,
  });
}

class FestivePainter extends CustomPainter {
  final double progress;
  final List<SnowParticle> snow;
  final List<LightParticle> lights;

  FestivePainter({
    required this.progress,
    required this.snow,
    required this.lights,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawLights(canvas, size);
    _drawSnow(canvas, size);
    _drawChristmasDecorations(canvas, size);
  }

  void _drawLights(Canvas canvas, Size size) {
    final cablePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();

    path.moveTo(0, 40);

    for (int i = 0; i <= 10; i++) {
      final x = size.width * (i / 10);

      final y = 38 +
          sin(
            progress * pi * 2 + i * 0.8,
          ) *
              5;

      path.lineTo(x, y);
    }

    canvas.drawPath(path, cablePaint);

    for (int i = 0; i < lights.length; i++) {
      final light = lights[i];

      final x = size.width * light.x;

      final y = 38 +
          sin(
            progress * pi * 2 + i * 0.8,
          ) *
              5;

      final glow =
          (sin(
            progress * pi * 2 +
                light.phase * pi * 2 +
                i,
          ) +
              1) /
              2;

      final glowPaint = Paint()
        ..color = light.color.withValues(
          alpha: 0.15 + glow * 0.35,
        )
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          12,
        );

      canvas.drawCircle(
        Offset(x, y),
        8 + glow * 5,
        glowPaint,
      );

      final bulbPaint = Paint()
        ..color = light.color;

      canvas.drawCircle(
        Offset(x, y),
        3.5,
        bulbPaint,
      );
    }
  }

  void _drawSnow(Canvas canvas, Size size) {
    final snowPaint = Paint();

    for (final flake in snow) {
      final y =
          ((flake.y + progress * flake.speed) % 1.0) *
              size.height;

      final x = flake.x * size.width +
          sin(
            progress * pi * 2 +
                flake.y * 10,
          ) *
              12 *
              flake.drift;

      snowPaint.color = Colors.white.withValues(
        alpha: 0.35 + (flake.size / 8) * 0.4,
      );

      canvas.drawCircle(
        Offset(x, y),
        flake.size / 2,
        snowPaint,
      );
    }
  }

  void _drawChristmasDecorations(
      Canvas canvas,
      Size size,
      ) {
    final treePaint = Paint()
      ..color = const Color(0xFF0D3B20);

    final treeX = 35.0;
    final treeBase = size.height - 35;

    final path = Path();

    path.moveTo(treeX, treeBase - 130);
    path.lineTo(treeX - 42, treeBase - 35);
    path.lineTo(treeX + 42, treeBase - 35);
    path.close();

    canvas.drawPath(path, treePaint);

    final trunkPaint = Paint()
      ..color = const Color(0xFF704214);

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(treeX, treeBase - 20),
        width: 13,
        height: 25,
      ),
      trunkPaint,
    );

    final starPaint = Paint()
      ..color = const Color(0xFFFFD700);

    canvas.drawCircle(
      Offset(treeX, treeBase - 138),
      7,
      starPaint,
    );

    final rightTreeX = size.width - 35;

    final rightPath = Path();

    rightPath.moveTo(
      rightTreeX,
      treeBase - 115,
    );

    rightPath.lineTo(
      rightTreeX - 38,
      treeBase - 30,
    );

    rightPath.lineTo(
      rightTreeX + 38,
      treeBase - 30,
    );

    rightPath.close();

    canvas.drawPath(
      rightPath,
      treePaint,
    );

    canvas.drawCircle(
      Offset(
        rightTreeX,
        treeBase - 123,
      ),
      6,
      starPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant FestivePainter oldDelegate,
      ) {
    return oldDelegate.progress != progress;
  }
}