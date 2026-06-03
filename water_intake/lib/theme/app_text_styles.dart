import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central typography token library for AQUA LOG.
///
/// All text styles use **Inter** (via Google Fonts).
///
/// Scale reference (matching Material 3 type roles):
///   displayLarge   → 57 / w400  (not used currently)
///   headlineLarge  → 32 / w700  (hero numeric value, e.g. "250 ml" on log screen)
///   headlineMedium → 22 / w900  (screen AppBar titles)
///   headlineSmall  → 18 / w800  (section card titles)
///   titleLarge     → 16 / w700  (section headers on home/history)
///   titleMedium    → 14 / w600  (list tile titles, form labels)
///   titleSmall     → 13 / w600  (snackbar text, button labels)
///   bodyLarge      → 14 / w400  (long body text)
///   bodyMedium     → 12 / w400  (secondary descriptions)
///   bodySmall      → 11 / w500  (subtitles, helper text)
///   labelLarge     → 12 / w600  (chips, trailing values, time badges)
///   labelMedium    → 11 / w600  (stat labels, legend items)
///   labelSmall     →  9 / w600  (micro labels e.g. badge requirements)
abstract class AppTextStyles {
  static bool isDark = false;

  // ── Primary brand colour alias ─────────────────────────────────────────
  static Color get _brand => isDark ? Colors.white : const Color(0xFF0D47A1);     // blue[900]
  static Color get _brandMid => isDark ? const Color(0xFF90CAF9) : const Color(0xFF1565C0);  // blue[800]
  static Color get _muted => isDark ? const Color(0xFFB0BEC5) : const Color(0xFF607D8B);     // blueGrey[200]
  static Color get _subtle => isDark ? const Color(0xFF78909C) : const Color(0xFF90A4AE);    // blueGrey[400]
  static const Color _danger = Color(0xFFE53935);    // red

  // ── App bar / screen titles ────────────────────────────────────────────
  /// Screen AppBar title (e.g. "AQUA LOG", "HISTORY")
  static TextStyle get appBarTitle => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
        color: _brand,
      );

  // ── Headline ───────────────────────────────────────────────────────────
  /// Large numeric hero value (e.g. "250 ml" on log screen)
  static TextStyle get heroValue => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: _brand,
      );

  /// Card primary title (e.g. "Today's Hydration")
  static TextStyle get headlineSmall => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: _brand,
      );

  // ── Section headers ────────────────────────────────────────────────────
  /// Section header on Home / History (e.g. "Quick Add", "Recent Entries")
  static TextStyle get sectionHeader => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: _brand,
      );

  /// Settings section header (above card groups)
  static TextStyle get settingsSectionHeader => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: _brand,
        letterSpacing: 0.4,
      );

  // ── Tile / list items ─────────────────────────────────────────────────
  /// Primary label in a settings/list tile (e.g. "Enable Reminders")
  static TextStyle get tileTitle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _brand,
      );

  /// Primary label — disabled state
  static TextStyle get tileTitleDisabled => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _subtle,
      );

  /// Secondary description line in a tile (e.g. "Frequency of notifications")
  static TextStyle get tileSubtitle => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: _muted,
      );

  /// Secondary description — disabled state
  static TextStyle get tileSubtitleDisabled => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: _subtle,
      );

  // ── Inline data values ─────────────────────────────────────────────────
  /// Bold numeric value displayed inside a card (e.g. "1 840 ml", "92%")
  static TextStyle get dataValue => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: _brand,
      );

  /// Smaller stat value (e.g. inside settings stats row)
  static TextStyle get statValue => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: _brand,
      );

  // ── Labels & chips ─────────────────────────────────────────────────────
  /// Chip / badge label (e.g. "Normal", "Active")
  static TextStyle get chipLabel => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _brand,
      );

  /// Chip sub-value (e.g. "2000 ml" below label)
  static TextStyle get chipSubLabel => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: _muted,
      );

  /// Trailing value badges (e.g. time pills, target badge)
  static TextStyle get badgeValue => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _brandMid,
      );

  /// Disabled trailing badge
  static TextStyle get badgeValueDisabled => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _subtle,
      );

  // ── Meta / helper ──────────────────────────────────────────────────────
  /// Motivational quote / card description underneath section title
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: _muted,
      );

  /// Chart axis labels, calendar day names
  static TextStyle get axisLabel => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _subtle,
      );

  /// Legend items, note micro-labels
  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: _muted,
      );

  /// Smallest label (e.g. badge requirements "3-Day Streak")
  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: _subtle,
      );

  /// Progress helper (e.g. "1240 ml / 2000 ml logged today")
  static TextStyle get progressHelper => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: _muted,
      );

  // ── Snackbar / buttons ─────────────────────────────────────────────────
  /// Snackbar body text
  static TextStyle get snackbar => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  /// Primary button label
  static TextStyle get buttonLabel => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );

  // ── Form fields ────────────────────────────────────────────────────────
  /// Input field value text
  static TextStyle get inputValue => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: _brand,
      );

  /// Input label / hint
  static TextStyle get inputLabel => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _muted,
      );

  /// Slider boundary labels (50 ml / 1500 ml)
  static TextStyle get sliderBound => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _subtle,
      );

  // ── Danger / destructive ───────────────────────────────────────────────
  static TextStyle get dangerTitle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _danger,
      );

  static TextStyle get dangerSubtitle => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Color(0xFFEF9A9A), // red[200]
      );

  // ── Calendar strip ─────────────────────────────────────────────────────
  static TextStyle calendarDayName({required bool isSelected}) =>
      GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: isSelected
            ? Colors.white.withOpacity(0.9)
            : const Color(0xFF90A4AE),
      );

  static TextStyle calendarDayNumber({required bool isSelected}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: isSelected
            ? Colors.white
            : (isDark ? const Color(0xFFBBDEFB) : const Color(0xFF0D47A1)),
      );

  // ── Tooltip ────────────────────────────────────────────────────────────
  static const TextStyle chartTooltip = TextStyle(
    fontFamily: 'Inter',
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 12,
  );

  // ── TextTheme helper ───────────────────────────────────────────────────
  /// Returns a [TextTheme] built from Inter for [ThemeData].
  static TextTheme get textTheme => GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 57, fontWeight: FontWeight.w400),
        headlineLarge: heroValue,
        headlineMedium: appBarTitle,
        headlineSmall: headlineSmall,
        titleLarge: sectionHeader,
        titleMedium: tileTitle,
        titleSmall: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _brandMid,
          letterSpacing: 0.4,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isDark ? Colors.white : const Color(0xFF0D1B2E),
        ),
        bodyMedium: caption,
        bodySmall: tileSubtitle,
        labelLarge: badgeValue,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
