import 'dart:math';
import 'package:flutter/material.dart';

class WaterWaveWidget extends StatefulWidget {
  final double progress; // 0.0 to 1.0+
  final double currentIntake;
  final double dailyTarget;
  final double size;

  const WaterWaveWidget({
    super.key,
    required this.progress,
    required this.currentIntake,
    required this.dailyTarget,
    this.size = 200,
  });

  @override
  State<WaterWaveWidget> createState() => _WaterWaveWidgetState();
}

class _WaterWaveWidgetState extends State<WaterWaveWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  final List<_Bubble> _bubbles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    for (int i = 0; i < 15; i++) {
      _bubbles.add(_Bubble(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.005 + _random.nextDouble() * 0.01,
        radius: 1.5 + _random.nextDouble() * 2.5,
        opacity: 0.1 + _random.nextDouble() * 0.4,
      ));
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _updateBubbles() {
    for (var bubble in _bubbles) {
      bubble.y -= bubble.speed;
      bubble.x += sin(bubble.y * 10) * 0.002;

      final topLimit = 1.0 - widget.progress.clamp(0.0, 1.0);
      if (bubble.y < topLimit) {
        bubble.y = 1.0;
        bubble.x = _random.nextDouble();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        _updateBubbles();

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Glow shadow behind circle (no black box) ──────────────
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(isDark ? 0.35 : 0.15),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),

              // ── Wave canvas clipped to a perfect circle ────────────────
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                    begin: 0.0, end: widget.progress.clamp(0.0, 1.1)),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (context, animatedProgress, _) {
                  return ClipOval(
                    child: CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: _WaveAndBubblePainter(
                        progress: animatedProgress,
                        waveValue: _waveController.value,
                        bubbles: _bubbles,
                        waterColor: const Color(0xFF29B6F6),
                        waveColor: const Color(0xFF039BE5),
                        // Light, transparent bg — no black box
                        bgColor: isDark
                            ? const Color(0xFF1A2E44)
                            : const Color(0xFFE1F5FE),
                      ),
                    ),
                  );
                },
              ),

              // ── Gradient ring border (purely visual, no background) ────
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  strokeWidth: 4,
                  colors: [
                    Colors.blue[300]!,
                    Colors.cyan[300]!,
                    Colors.blue[600]!,
                  ],
                ),
              ),

              // ── Overlay text ───────────────────────────────────────────
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(widget.progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: widget.size * 0.18,
                      fontWeight: FontWeight.w900,
                      color: widget.progress >= 0.5
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.blue[800]),
                      shadows: [
                        Shadow(
                          color: Colors.blue[900]!.withOpacity(0.35),
                          blurRadius: 6,
                          offset: const Offset(1, 2),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${widget.currentIntake.toStringAsFixed(0)} / ${widget.dailyTarget.toStringAsFixed(0)} ml',
                    style: TextStyle(
                      fontSize: widget.size * 0.08,
                      fontWeight: FontWeight.w600,
                      color: widget.progress >= 0.6
                          ? Colors.white.withOpacity(0.9)
                          : (isDark ? Colors.blue[200] : Colors.blue[600]),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    widget.progress >= 1.0
                        ? Icons.check_circle
                        : Icons.water_drop,
                    color: widget.progress >= 0.7
                        ? Colors.white.withOpacity(0.9)
                        : (isDark ? Colors.blue[300] : Colors.blue[400]),
                    size: widget.size * 0.1,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Ring painter — draws only the border stroke, no fill ────────────────────
class _RingPainter extends CustomPainter {
  final double strokeWidth;
  final List<Color> colors;
  _RingPainter({required this.strokeWidth, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        colors: [...colors, colors.first],
        startAngle: 0,
        endAngle: 2 * pi,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.strokeWidth != strokeWidth;
}

class _Bubble {
  double x;
  double y;
  double speed;
  double radius;
  double opacity;

  _Bubble({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.opacity,
  });
}

class _WaveAndBubblePainter extends CustomPainter {
  final double progress;
  final double waveValue;
  final List<_Bubble> bubbles;
  final Color waterColor;
  final Color waveColor;
  final Color bgColor;

  _WaveAndBubblePainter({
    required this.progress,
    required this.waveValue,
    required this.bubbles,
    required this.waterColor,
    required this.waveColor,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw circular background (not a rectangle — avoids the black box)
    final center = Offset(size.width / 2, size.height / 2);
    final bgPaint = Paint()..color = bgColor;
    canvas.drawCircle(center, size.width / 2, bgPaint);

    if (progress <= 0.0) return;

    final double waterHeight = size.height * progress.clamp(0.0, 1.0);
    final double baseHeight = size.height - waterHeight;

    // 2. Back wave
    final backWavePaint = Paint()..color = waterColor.withOpacity(0.65);
    final backPath = Path();
    backPath.moveTo(0, baseHeight);
    for (double x = 0; x <= size.width; x++) {
      final double waveY =
          8 * sin((x / size.width * 2.5 * pi) + (waveValue * 2 * pi));
      backPath.lineTo(x, baseHeight + waveY);
    }
    backPath.lineTo(size.width, size.height);
    backPath.lineTo(0, size.height);
    backPath.close();
    canvas.drawPath(backPath, backWavePaint);

    // 3. Bubbles
    for (var bubble in bubbles) {
      if (bubble.y >= (1.0 - progress)) {
        final bubblePaint = Paint()
          ..color = Colors.white.withOpacity(bubble.opacity)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(bubble.x * size.width, bubble.y * size.height),
          bubble.radius,
          bubblePaint,
        );
      }
    }

    // 4. Front wave
    final frontWavePaint = Paint()..color = waveColor;
    final frontPath = Path();
    frontPath.moveTo(0, baseHeight);
    for (double x = 0; x <= size.width; x++) {
      final double waveY = 6 *
          cos((x / size.width * 2 * pi) -
              (waveValue * 2 * pi) +
              (pi / 3));
      frontPath.lineTo(x, baseHeight + waveY);
    }
    frontPath.lineTo(size.width, size.height);
    frontPath.lineTo(0, size.height);
    frontPath.close();
    canvas.drawPath(frontPath, frontWavePaint);
  }

  @override
  bool shouldRepaint(covariant _WaveAndBubblePainter oldDelegate) => true;
}
