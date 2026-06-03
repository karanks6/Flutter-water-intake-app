import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/intake_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_text_styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ── Light theme ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFFF3F9FD),
        cardColor: Colors.white,
        textTheme: AppTextStyles.textTheme,
      );

  // ── Dark theme ───────────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ).copyWith(
          surface: const Color(0xFF101624),
          onSurface: Colors.white,
          primary: const Color(0xFF90CAF9),
          onPrimary: const Color(0xFF0D1B2E),
          surfaceContainerHighest: const Color(0xFF1A2336),
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFF0A0F1E),
        cardColor: const Color(0xFF141B2D),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D1425),
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black26,
        ),
        // Dark text theme: same Inter font, lighter colors
        textTheme: GoogleFonts.interTextTheme().copyWith(
          headlineLarge: GoogleFonts.inter(
              fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
          headlineMedium: GoogleFonts.inter(
              fontSize: 22, fontWeight: FontWeight.w900,
              letterSpacing: 2.0, color: Colors.white),
          headlineSmall: GoogleFonts.inter(
              fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
          titleLarge: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
          titleMedium: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
          titleSmall: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w800,
              color: const Color(0xFFBBDEFB), letterSpacing: 0.4),
          bodyLarge: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
          bodyMedium: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w500,
              color: const Color(0xFF90A4AE)),
          bodySmall: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w500,
              color: const Color(0xFF78909C)),
          labelLarge: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: const Color(0xFFBBDEFB)),
          labelMedium: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: const Color(0xFF90A4AE)),
          labelSmall: GoogleFonts.inter(
              fontSize: 9, fontWeight: FontWeight.w600,
              color: const Color(0xFF78909C)),
        ),
        dividerColor: const Color(0xFF1E2A3E),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF141B2D),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IntakeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          AppTextStyles.isDark = themeProvider.isDark;
          return MaterialApp(
            title: 'AQUA LOG',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}