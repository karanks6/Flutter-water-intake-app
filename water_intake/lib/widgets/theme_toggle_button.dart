import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// Animated sun/moon toggle button placed in every AppBar's [actions].
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: RotationTransition(
                  turns: Tween<double>(begin: 0.3, end: 0.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: IconButton(
              key: ValueKey(themeProvider.isDark),
              tooltip: themeProvider.isDark ? 'Switch to light mode' : 'Switch to dark mode',
              icon: Icon(
                themeProvider.isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                size: 22,
              ),
              color: themeProvider.isDark
                  ? const Color(0xFFFFD54F) // warm amber for the sun
                  : const Color(0xFF1565C0), // dark blue for the moon
              onPressed: () {
                HapticFeedback.lightImpact();
                themeProvider.toggleTheme();
              },
            ),
          ),
        );
      },
    );
  }
}
