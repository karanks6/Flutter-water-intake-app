import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/intake_provider.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dropAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // 1. Drop falling animation (first 35% of duration)
    // Starts high enough to be off-screen and falls quickly.
    _dropAnimation = Tween<double>(begin: -500.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeInCubic),
      ),
    );

    // 2. Ripple expansion animation (35% to 75% of duration)
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    // 3. Logo/text fade in (40% to 90% of duration)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.90, curve: Curves.easeIn),
      ),
    );

    // 4. Logo scale (40% to 100% of duration)
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 1.0, curve: Curves.elasticOut),
      ),
    );

    _initializeAppAndAnimate();
  }

  Future<void> _initializeAppAndAnimate() async {
    // 1. Run heavy initialization FIRST (database, notifications, platform channels).
    // Doing this in parallel with the animation causes the main thread to drop
    // frames, completely skipping the fast droplet animation on many Android devices.
    try {
      await Provider.of<IntakeProvider>(context, listen: false).initialize();
    } catch (e) {
      debugPrint('Error initializing IntakeProvider: $e');
    }

    // 2. Start the fluid animation only after the main thread is completely free
    if (mounted) {
      await _controller.forward();
      _navigateToMainShell();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToMainShell() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainShellScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Clean fade and scale entry transition
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.08, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D1B2A), // Very deep navy
              Color(0xFF1B263B), // Soft dark slate
              Color(0xFF003049), // Deep aqua tint
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                // Custom droplet and ripple drawing
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SplashPhysicsPainter(
                      dropYOffset: _dropAnimation.value,
                      rippleProgress: _rippleAnimation.value,
                      showRipple: _controller.value >= 0.35,
                    ),
                  ),
                ),

                // Logo Text and Icon overlay
                Center(
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 120), // Spacing below impact point
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.blue[300]!.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF00E5FF), Color(0xFF00B0FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: const Icon(
                                Icons.water_drop_rounded,
                                size: 54,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'AQUA LOG',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 6,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your Hydration Assistant',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                              color: Colors.blue[200]!.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SplashPhysicsPainter extends CustomPainter {
  final double dropYOffset;
  final double rippleProgress;
  final bool showRipple;

  _SplashPhysicsPainter({
    required this.dropYOffset,
    required this.rippleProgress,
    required this.showRipple,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    // Impact point slightly above center
    final centerY = size.height * 0.42;

    // 1. Draw falling droplet
    // We draw the droplet as long as it hasn't finished falling
    if (dropYOffset < 0.0) {
      final dropPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFF2979FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromCircle(center: Offset(centerX, centerY + dropYOffset), radius: 14))
        ..style = PaintingStyle.fill;

      // Draw droplet shape (tear-drop path)
      final dropPath = Path();
      final dropCenterY = centerY + dropYOffset;
      dropPath.moveTo(centerX, dropCenterY - 18); // Tip
      dropPath.cubicTo(
        centerX - 10, dropCenterY - 4,
        centerX - 12, dropCenterY + 10,
        centerX, dropCenterY + 12, // Round bottom
      );
      dropPath.cubicTo(
        centerX + 12, dropCenterY + 10,
        centerX + 10, dropCenterY - 4,
        centerX, dropCenterY - 18,
      );
      dropPath.close();

      canvas.drawPath(dropPath, dropPaint);
    }

    // 2. Draw expanding ripple rings on impact
    if (showRipple && rippleProgress > 0.0) {
      final double maxRadius = size.width * 0.55;
      final double currentRadius = rippleProgress * maxRadius;
      final double opacity = (1.0 - rippleProgress).clamp(0.0, 1.0);

      // Primary wave ring
      final ripplePaint = Paint()
        ..color = const Color(0xFF00E5FF).withOpacity(opacity * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * (1.0 - rippleProgress) + 1;
      canvas.drawCircle(Offset(centerX, centerY), currentRadius, ripplePaint);

      // Secondary delay wave ring (inside primary)
      if (rippleProgress > 0.3) {
        final double innerRadius = (rippleProgress - 0.3) / 0.7 * maxRadius;
        final double innerOpacity = (1.0 - (rippleProgress - 0.3) / 0.7).clamp(0.0, 1.0);
        final innerRipplePaint = Paint()
          ..color = const Color(0xFF2979FF).withOpacity(innerOpacity * 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * innerOpacity + 0.5;
        canvas.drawCircle(Offset(centerX, centerY), innerRadius, innerRipplePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SplashPhysicsPainter oldDelegate) {
    return oldDelegate.dropYOffset != dropYOffset ||
        oldDelegate.rippleProgress != rippleProgress ||
        oldDelegate.showRipple != showRipple;
  }
}
