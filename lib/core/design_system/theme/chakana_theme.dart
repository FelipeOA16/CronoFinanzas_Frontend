import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../brand/crono_brand_theme.dart';
import '../tokens/theme_tokens.dart';

abstract class ChakanaTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: CFColors.verdeValle,
        onPrimary: Colors.white,
        primaryContainer: CFColors.surfaceAlt,
        onPrimaryContainer: CFColors.piedraOscura,
        secondary: CFColors.azulAndino,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFDDE8EF),
        onSecondaryContainer: CFColors.azulAndino,
        tertiary: CFColors.oroInca,
        onTertiary: CFColors.piedraOscura,
        error: CFColors.danger,
        onError: Colors.white,
        surface: CFColors.surface,
        onSurface: CFColors.textPrimary,
        outline: CFColors.border,
        surfaceContainerHighest: CFColors.surfaceAlt,
        onSurfaceVariant: CFColors.textSecondary,
      ),
      scaffoldBackgroundColor: CFColors.marfil,
      extensions: const [CronoBrandTheme.standard],
    );

    return base.copyWith(
      textTheme: CFTypography.textTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: CFColors.marfil,
        foregroundColor: CFColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: CFColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: CFColors.surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(
          horizontal: CFSpacing.md,
          vertical: CFSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CFRadius.lg),
          side: const BorderSide(color: CFColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CFColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: CFSpacing.md,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CFRadius.md),
          borderSide: const BorderSide(color: CFColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CFRadius.md),
          borderSide: const BorderSide(color: CFColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CFRadius.md),
          borderSide: const BorderSide(color: CFColors.verdeValle, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CFRadius.md),
          borderSide: const BorderSide(color: CFColors.danger),
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: CFColors.textSecondary,
        ),
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: CFColors.textMuted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: CFColors.verdeValle,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: CFSpacing.md,
            horizontal: CFSpacing.xl,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CFRadius.md),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CFColors.verdeValle,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            vertical: CFSpacing.md,
            horizontal: CFSpacing.xl,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CFRadius.md),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CFColors.azulAndino,
          side: const BorderSide(color: CFColors.azulAndino),
          padding: const EdgeInsets.symmetric(
            vertical: CFSpacing.md,
            horizontal: CFSpacing.xl,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CFRadius.md),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CFColors.azulAndino,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: CFColors.surface,
        selectedColor: CFColors.surfaceAlt,
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: CFColors.textPrimary,
        ),
        side: const BorderSide(color: CFColors.border),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: CFSpacing.sm,
          vertical: CFSpacing.xxs,
        ),
      ),
      badgeTheme: const BadgeThemeData(
        backgroundColor: CFColors.terracota,
        textColor: Colors.white,
        smallSize: 8,
        largeSize: 20,
        padding: EdgeInsets.symmetric(horizontal: CFSpacing.xs),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : CFColors.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? CFColors.verdeValle
              : CFColors.surfaceMuted,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(CFColors.border),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: CFColors.surface,
        elevation: 6,
        shadowColor: CFColors.piedraOscura.withValues(alpha: 0.16),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CFRadius.md),
          side: const BorderSide(color: CFColors.border),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: CFColors.textPrimary,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(44, 48)),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.white
                : CFColors.azulAndino,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? CFColors.verdeValle
                : CFColors.surface,
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(color: CFColors.border),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(CFRadius.md),
            ),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: CFColors.surface,
        selectedItemColor: CFColors.verdeValle,
        unselectedItemColor: CFColors.textMuted,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: CFColors.surface,
        indicatorColor: CFColors.surfaceAlt,
        elevation: 8,
        height: 72,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? CFColors.verdeValle
                : CFColors.textMuted,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
            color: states.contains(WidgetState.selected)
                ? CFColors.verdeValle
                : CFColors.textMuted,
          );
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: CFColors.verdeValle,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      dividerTheme: const DividerThemeData(
        color: CFColors.border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CFColors.piedraOscura,
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CFRadius.md),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: CFColors.verdeValle,
        linearTrackColor: CFColors.surfaceMuted,
      ),
    );
  }
}
