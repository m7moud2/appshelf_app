import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cool slate + soft sage — matches AppShelf web DESIGN.md / SCSS tokens.
class AsColors {
  static const Color bg = Color(0xFFEEF2F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF152226);
  static const Color muted = Color(0xFF5E6E72);
  static const Color primary = Color(0xFF2F6A63);
  static const Color primaryDeep = Color(0xFF234F4A);
  static const Color accent = Color(0xFF6D8578);
  static const Color success = Color(0xFF4D7A5C);
  static const Color warning = Color(0xFF8F7548);
  static const Color danger = Color(0xFF8A554C);
  static const Color border = Color(0x1A152226);
  static const Color softPrimary = Color(0xFFD9E8E5);
}

class AsSpacing {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 28;
}

class AsRadii {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 16;
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AsColors.primary,
        onPrimary: Colors.white,
        secondary: AsColors.accent,
        onSecondary: AsColors.text,
        error: AsColors.danger,
        onError: Colors.white,
        surface: AsColors.surface,
        onSurface: AsColors.text,
      ),
      scaffoldBackgroundColor: AsColors.bg,
    );

    TextTheme textTheme;
    try {
      textTheme = GoogleFonts.cairoTextTheme(base.textTheme).apply(
        bodyColor: AsColors.text,
        displayColor: AsColors.text,
      );
    } catch (_) {
      textTheme = base.textTheme.apply(
        bodyColor: AsColors.text,
        displayColor: AsColors.text,
      );
    }

    TextStyle cairo({
      double? fontSize,
      FontWeight? fontWeight,
      Color? color,
    }) {
      try {
        return GoogleFonts.cairo(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      } catch (_) {
        return TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      }
    }

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AsRadii.md),
      borderSide: const BorderSide(color: AsColors.border),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AsColors.bg.withOpacity(0.92),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: AsColors.text,
        titleTextStyle: cairo(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AsColors.text,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AsColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AsRadii.md),
          ),
          textStyle: cairo(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AsColors.primaryDeep,
          side: const BorderSide(color: AsColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AsRadii.md),
          ),
          textStyle: cairo(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AsColors.primaryDeep,
          textStyle: cairo(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AsColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AsRadii.md),
          borderSide: const BorderSide(color: AsColors.primary, width: 1.4),
        ),
        labelStyle: cairo(color: AsColors.muted),
        hintStyle: cairo(color: AsColors.muted.withOpacity(0.8)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AsColors.softPrimary.withOpacity(0.45),
        selectedColor: AsColors.softPrimary,
        labelStyle: cairo(fontWeight: FontWeight.w600, color: AsColors.text),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AsRadii.sm),
        ),
      ),
      cardTheme: CardTheme(
        color: AsColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AsRadii.lg),
          side: const BorderSide(color: AsColors.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AsColors.surface,
        indicatorColor: AsColors.softPrimary,
        labelTextStyle: WidgetStatePropertyAll(
          cairo(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AsColors.text,
        contentTextStyle: cairo(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AsRadii.sm),
        ),
      ),
      dividerColor: AsColors.border,
    );
  }
}
