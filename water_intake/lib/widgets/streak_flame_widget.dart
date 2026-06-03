import 'package:flutter/material.dart';

class StreakFlameWidget extends StatefulWidget {
  final int streakCount;
  final double size;

  const StreakFlameWidget({
    super.key,
    required this.streakCount,
    this.size = 60,
  });

  @override
  State<StreakFlameWidget> createState() => _StreakFlameWidgetState();
}

class _StreakFlameWidgetState extends State<StreakFlameWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Continuous soft pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasStreak = widget.streakCount > 0;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        // Subtle scale pulse and opacity flicker
        final scale = 1.0 + (hasStreak ? _pulseController.value * 0.08 : 0.0);
        final flicker = 0.85 + (hasStreak ? _pulseController.value * 0.15 : 0.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: flicker,
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _FlamePainter(
                    hasStreak: hasStreak,
                    pulseValue: _pulseController.value,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                gradient: hasStreak
                    ? const LinearGradient(
                        colors: [Color(0xFFFF9100), Color(0xFFFF3D00)],
                      )
                    : const LinearGradient(
                        colors: [Colors.grey, Colors.blueGrey],
                      ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (hasStreak)
                    BoxShadow(
                      color: const Color(0xFFFF3D00).withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Text(
                '${widget.streakCount} Day${widget.streakCount != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FlamePainter extends CustomPainter {
  final bool hasStreak;
  final double pulseValue;

  _FlamePainter({required this.hasStreak, required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Draw background shadow glow for active flames
    if (hasStreak) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFF9100).withOpacity(0.2 + (pulseValue * 0.1))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(Offset(width / 2, height / 2 + 5), width * 0.35, glowPaint);
    }

    final path = Path();
    // Start at bottom center
    path.moveTo(width * 0.5, height * 0.95);

    // Left base curve
    path.cubicTo(
      width * 0.15, height * 0.85,  // Control point 1
      width * 0.10, height * 0.50,  // Control point 2
      width * 0.35, height * 0.30,  // End point
    );

    // Left flicker curve up to main tip
    path.cubicTo(
      width * 0.40, height * 0.20,
      width * 0.45, height * 0.10 - (pulseValue * 5),
      width * 0.50, height * 0.05 - (pulseValue * 5), // dynamic tip height
    );

    // Right flicker curve down
    path.cubicTo(
      width * 0.55, height * 0.15,
      width * 0.60, height * 0.25,
      width * 0.65, height * 0.35,
    );

    // Right base curve
    path.cubicTo(
      width * 0.90, height * 0.55,
      width * 0.85, height * 0.85,
      width * 0.50, height * 0.95,
    );

    path.close();

    // Setup active flame color gradient or inactive grey
    final Paint flamePaint = Paint();
    if (hasStreak) {
      flamePaint.shader = LinearGradient(
        colors: const [
          Color(0xFFFF3D00), // Intense Orange-Red (bottom)
          Color(0xFFFF9100), // Bright Orange (middle)
          Color(0xFFFFD600), // Yellow (tip)
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, height));
    } else {
      flamePaint.shader = LinearGradient(
        colors: [
          Colors.grey[700]!,
          Colors.grey[500]!,
          Colors.grey[400]!,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, height));
    }

    canvas.drawPath(path, flamePaint);

    // Draw inner flame detail
    if (hasStreak) {
      final innerPath = Path();
      innerPath.moveTo(width * 0.5, height * 0.85);

      innerPath.cubicTo(
        width * 0.30, height * 0.80,
        width * 0.28, height * 0.55,
        width * 0.45, height * 0.42,
      );
      innerPath.cubicTo(
        width * 0.48, height * 0.35,
        width * 0.49, height * 0.25,
        width * 0.50, height * 0.20,
      );
      innerPath.cubicTo(
        width * 0.51, height * 0.30,
        width * 0.55, height * 0.45,
        width * 0.55, height * 0.55,
      );
      innerPath.cubicTo(
        width * 0.70, height * 0.65,
        width * 0.70, height * 0.80,
        width * 0.5, height * 0.85,
      );
      innerPath.close();

      final innerFlamePaint = Paint()
        ..shader = LinearGradient(
          colors: const [
            Color(0xFFFFEA00), // Bright Yellow
            Color(0xFFFFFFFF), // White core
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ).createShader(Rect.fromLTWH(0, 0, width, height));

      canvas.drawPath(innerPath, innerFlamePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FlamePainter oldDelegate) {
    return oldDelegate.hasStreak != hasStreak ||
        oldDelegate.pulseValue != pulseValue;
  }
}
