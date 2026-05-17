import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Custom Ember colors not in ColorScheme
  static const Color bg0 = Color(0xFF161412);
  static const Color bg1 = Color(0xFF231F1B);
  static const Color bg2 = Color(0xFF2E2923);
  static const Color bg3 = Color(0xFF3D352C);
  
  static const Color txt0 = Color(0xFFEDE6DD);
  static const Color txt1 = Color(0xFFD4C4B0);
  static const Color txt2 = Color(0xFF8A8078);
  static const Color txt3 = Color(0xFF5A5248);
  
  static const Color error = Color(0xFFD44A3A);
  
  static const Color green = Color(0xFF6B9E3A);
  static const Color greenDim = Color(0xFF243D12);
  static const Color coralDim = Color(0xFF7A3520);
  static const Color amber = Color(0xFFE8A83E);
  static const Color amberDark = Color(0xFFC8901A);

  /// DM Mono style for large stat values (e.g., volume, weight)
  static TextStyle monoLarge({Color? color}) => GoogleFonts.dmMono(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: color ?? const Color(0xFFEDE6DD),
  );

  /// DM Mono style for inline data displays (e.g., "100kg × 8")
  static TextStyle monoMedium({Color? color}) => GoogleFonts.dmMono(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: color ?? const Color(0xFFD4C4B0),
  );

  /// DM Mono style for small data (e.g., timer, input values)
  static TextStyle monoSmall({Color? color}) => GoogleFonts.dmMono(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: color ?? const Color(0xFFD4C4B0),
  );

  /// DM Mono style for input fields
  static TextStyle monoInput({Color? color}) => GoogleFonts.dmMono(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: color ?? const Color(0xFFEDE6DD),
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        // Surfaces
        surface: Color(0xFF161412),              // bg0 — scaffold background
        surfaceContainerHighest: Color(0xFF231F1B), // bg1 — card backgrounds
        surfaceContainerHigh: Color(0xFF2E2923),   // bg2 — dialogs, elevated surfaces
        outline: Color(0xFF3D352C),              // bg3 — borders, dividers
        outlineVariant: Color(0xFF3D352C),       // same as bg3 for subtle borders

        // Primary (Amber)
        primary: Color(0xFFE8A83E),              // amber — buttons, active states, FABs
        onPrimary: Color(0xFF1C1000),            // dark text on amber surfaces
        primaryContainer: Color(0xFFC8901A),     // amberDark — pressed states
        onPrimaryContainer: Color(0xFFEDE6DD),   // light text on dark amber

        // Secondary
        secondary: Color(0xFFD4C4B0),            // txt1 tone
        onSecondary: Color(0xFF231F1B),          // bg1
        secondaryContainer: Color(0xFF2E2923),   // bg2
        onSecondaryContainer: Color(0xFFEDE6DD), // txt0

        // Tertiary (Coral)
        tertiary: Color(0xFFC75D3A),             // coral — Finish button, accents
        onTertiary: Color(0xFFFDE8DF),           // light text on coral
        tertiaryContainer: Color(0xFF7A3520),    // coralDim — tinted backgrounds
        onTertiaryContainer: Color(0xFFFDE8DF),  // light text on coralDim

        // Error
        error: Color(0xFFD44A3A),                // error — destructive actions
        onError: Color(0xFFFDE8DF),              // light text on error
        errorContainer: Color(0xFF7A3520),       // same as coralDim
        onErrorContainer: Color(0xFFFDE8DF),     // light text on errorContainer

        // Text
        onSurface: Color(0xFFEDE6DD),            // txt0 — primary text
        onSurfaceVariant: Color(0xFFD4C4B0),     // txt1 — secondary text

        // Inverse (for SnackBars)
        inverseSurface: Color(0xFFEDE6DD),       // txt0
        onInverseSurface: Color(0xFF161412),     // bg0
        inversePrimary: Color(0xFFC8901A),       // amberDark
      ),
      scaffoldBackgroundColor: const Color(0xFF161412),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF161412),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        // Ensure all text styles use the correct colors
        titleLarge: GoogleFonts.dmSans(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFEDE6DD), // txt0
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFEDE6DD), // txt0
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFD4C4B0), // txt1
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFD4C4B0), // txt1
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF8A8078), // txt2
        ),
        labelLarge: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFEDE6DD), // txt0
        ),
        labelSmall: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF8A8078), // txt2
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
