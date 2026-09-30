import 'package:flutter/material.dart';

import 'vulcan_colors.dart';

/// App-owned Material 3 light and dark themes (Nord-influenced tokens).
abstract final class VulcanTheme {
  static const String fontFamily = 'Manrope';

  static const Color _darkBase = Color(0xFF22201F);
  static const Color _darkSurface = Color(0xFF282624);
  static const Color _darkPrimary = Color(0xFF88C0D0);
  static const Color _darkOnPrimary = Color(0xFF12181B);
  static const Color _darkOnSurface = Color(0xFFEDEAE6);
  static const Color _darkOnSurfaceVariant = Color(0xFFA8A29B);

  /// Contrast-adjusted vs `design.md` `#6B655F` (fails 4.5:1 on surface).
  static const Color _darkDisabled = Color(0xFF9A938C);

  /// Error *text* on surfaces; deeper fills use [VulcanColors.danger].
  static const Color _darkErrorOnSurface = Color(0xFFE08B93);
  static const Color _darkOutline = Color(0xFF88C0D0);

  static const Color _lightBase = Color(0xFFECEFF4);
  static const Color _lightSurface = Color(0xFFE5E9F0);
  static const Color _lightPrimary = Color(0xFF3B5B7F);
  static const Color _lightOnPrimary = Color(0xFFFFFFFF);
  static const Color _lightOnSurface = Color(0xFF2E3440);
  static const Color _lightOnSurfaceVariant = Color(0xFF4C566A);
  static const Color _lightDisabled = Color(0xFF5E6674);

  /// Matches [VulcanColors.light.danger] for [ColorScheme.error] and fills.
  static const Color _lightError = Color(0xFF9E3A42);
  static const Color _lightOutline = Color(0xFF3B5B7F);
  static const Color _lightPrimaryContainer = Color(0xFF88C0D0);
  static const Color _lightOnPrimaryContainer = Color(0xFF2E3440);

  static const double radiusCard = 20;
  static const double radiusControl = 14;
  static const double radiusFab = 999;

  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: _darkPrimary,
      onPrimary: _darkOnPrimary,
      primaryContainer: Color(0xFF5E81AC),
      onPrimaryContainer: _darkOnSurface,
      secondary: Color(0xFF5E81AC),
      onSecondary: _darkOnPrimary,
      secondaryContainer: Color(0xFF3B4252),
      onSecondaryContainer: _darkOnSurface,
      tertiary: Color(0xFFD08770),
      onTertiary: _darkOnPrimary,
      error: _darkErrorOnSurface,
      onError: _darkOnPrimary,
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      onSurfaceVariant: _darkOnSurfaceVariant,
      outline: _darkOutline,
      outlineVariant: Color(0xFF4C4A47),
      shadow: Color(0xFF141312),
      scrim: Color(0xFF000000),
      inverseSurface: _lightOnSurface,
      onInverseSurface: _lightBase,
      inversePrimary: _lightPrimary,
      surfaceTint: _darkPrimary,
    ),
    scaffoldBackground: _darkBase,
    disabledColor: _darkDisabled,
    extension: VulcanColors.dark,
  );

  static ThemeData light() => _build(
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: _lightPrimary,
      onPrimary: _lightOnPrimary,
      primaryContainer: _lightPrimaryContainer,
      onPrimaryContainer: _lightOnPrimaryContainer,
      secondary: Color(0xFF5E81AC),
      onSecondary: _lightOnPrimary,
      secondaryContainer: Color(0xFFD8DEE9),
      onSecondaryContainer: _lightOnSurface,
      tertiary: Color(0xFFD08770),
      onTertiary: _lightOnPrimary,
      error: _lightError,
      onError: _lightOnPrimary,
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      onSurfaceVariant: _lightOnSurfaceVariant,
      outline: _lightOutline,
      outlineVariant: Color(0xFFB8C0CC),
      shadow: Color(0xFFB8C0CC),
      scrim: Color(0xFF000000),
      inverseSurface: _darkOnSurface,
      onInverseSurface: _darkBase,
      inversePrimary: _darkPrimary,
      surfaceTint: _lightPrimary,
    ),
    scaffoldBackground: _lightBase,
    disabledColor: _lightDisabled,
    extension: VulcanColors.light,
  );

  static TextStyle displayStyle(Brightness brightness) => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 32,
    height: 1.2,
    color: brightness == Brightness.dark ? _darkOnSurface : _lightOnSurface,
  );

  static TextStyle headingStyle(Brightness brightness) => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 20,
    height: 1.25,
    color: brightness == Brightness.dark ? _darkOnSurface : _lightOnSurface,
  );

  static TextStyle bodyStyle(Brightness brightness) => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 1.4,
    color: brightness == Brightness.dark ? _darkOnSurface : _lightOnSurface,
  );

  static TextStyle captionStyle(Brightness brightness) => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 1.35,
    color: brightness == Brightness.dark
        ? _darkOnSurfaceVariant
        : _lightOnSurfaceVariant,
  );

  static TextStyle statStyle(Brightness brightness) => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 24,
    height: 1.2,
    fontFeatures: const [FontFeature.tabularFigures()],
    color: brightness == Brightness.dark ? _darkOnSurface : _lightOnSurface,
  );

  static TextStyle timerStyle(Brightness brightness) => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 1.2,
    fontFeatures: const [FontFeature.tabularFigures()],
    color: brightness == Brightness.dark ? _darkOnSurface : _lightOnSurface,
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color disabledColor,
    required VulcanColors extension,
  }) {
    final textTheme = _textTheme(brightness);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      disabledColor: disabledColor,
      fontFamily: fontFamily,
      textTheme: textTheme,
      extensions: [extension],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scaffoldBackground,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: headingStyle(brightness),
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return captionStyle(brightness).copyWith(
            color: states.contains(WidgetState.selected)
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          );
        }),
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _filledButtonStyle(extension, colorScheme),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _outlinedButtonStyle(colorScheme),
      ),
      textButtonTheme: TextButtonThemeData(
        style: _textButtonStyle(colorScheme),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        focusElevation: 4,
        hoverElevation: 4,
        highlightElevation: 6,
        shape: const StadiumBorder(),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 24),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: extension.surfaceSunken,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: extension.focusBorder, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: bodyStyle(brightness)
            .copyWith(color: colorScheme.onSurfaceVariant),
        hintStyle: bodyStyle(brightness).copyWith(color: disabledColor),
        errorStyle: captionStyle(brightness).copyWith(color: colorScheme.error),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
        titleTextStyle: headingStyle(brightness),
        contentTextStyle: bodyStyle(brightness),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: extension.surfaceSunken,
        selectedColor: colorScheme.primaryContainer,
        disabledColor: extension.surfaceSunken.withValues(alpha: 0.5),
        labelStyle: bodyStyle(brightness),
        secondaryLabelStyle: captionStyle(brightness),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: bodyStyle(brightness)
            .copyWith(color: colorScheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusControl),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: extension.surfaceSunken,
        circularTrackColor: extension.surfaceSunken,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          tapTargetSize: MaterialTapTargetSize.padded,
          foregroundColor: colorScheme.onSurface,
          focusColor: colorScheme.primary.withValues(alpha: 0.12),
          highlightColor: colorScheme.primary.withValues(alpha: 0.08),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      visualDensity: VisualDensity.standard,
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    return TextTheme(
      displayLarge: displayStyle(brightness),
      displayMedium: displayStyle(brightness).copyWith(fontSize: 28),
      displaySmall: displayStyle(brightness).copyWith(fontSize: 24),
      headlineLarge: headingStyle(brightness).copyWith(fontSize: 22),
      headlineMedium: headingStyle(brightness),
      headlineSmall: headingStyle(brightness).copyWith(fontSize: 18),
      titleLarge: statStyle(brightness),
      titleMedium: bodyStyle(brightness).copyWith(fontWeight: FontWeight.w700),
      titleSmall: bodyStyle(brightness).copyWith(fontSize: 14),
      bodyLarge: bodyStyle(brightness),
      bodyMedium: bodyStyle(brightness).copyWith(fontSize: 14),
      bodySmall: captionStyle(brightness),
      labelLarge: bodyStyle(brightness).copyWith(fontWeight: FontWeight.w700),
      labelMedium: captionStyle(brightness),
      labelSmall: captionStyle(brightness).copyWith(fontSize: 11),
    );
  }

  static ButtonStyle _filledButtonStyle(
    VulcanColors extension,
    ColorScheme colorScheme,
  ) {
    return ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.12);
        }
        return colorScheme.primary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.38);
        }
        return colorScheme.onPrimary;
      }),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusControl),
        ),
      ),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return BorderSide(color: extension.focusBorder, width: 2);
        }
        if (states.contains(WidgetState.pressed)) {
          return BorderSide(color: extension.primaryDeep, width: 2);
        }
        return BorderSide.none;
      }),
    );
  }

  static ButtonStyle _outlinedButtonStyle(ColorScheme colorScheme) {
    return ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusControl),
        ),
      ),
      side: WidgetStateProperty.resolveWith((states) {
        final width = states.contains(WidgetState.focused) ? 2.0 : 1.0;
        final color = states.contains(WidgetState.focused)
            ? colorScheme.primary
            : colorScheme.outline;
        return BorderSide(color: color, width: width);
      }),
    );
  }

  static ButtonStyle _textButtonStyle(ColorScheme colorScheme) {
    return ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.38);
        }
        return colorScheme.primary;
      }),
      overlayColor: WidgetStatePropertyAll(
        colorScheme.primary.withValues(alpha: 0.08),
      ),
    );
  }

  /// Documented token pairs for contrast acceptance tests.
  static List<({Color foreground, Color background, String label})>
  contrastPairs(Brightness brightness) {
    final ext = brightness == Brightness.dark
        ? VulcanColors.dark
        : VulcanColors.light;
    final base = brightness == Brightness.dark ? _darkBase : _lightBase;
    final surface = brightness == Brightness.dark
        ? _darkSurface
        : _lightSurface;
    final onSurface = brightness == Brightness.dark
        ? _darkOnSurface
        : _lightOnSurface;
    final onSurfaceVariant = brightness == Brightness.dark
        ? _darkOnSurfaceVariant
        : _lightOnSurfaceVariant;
    final primary = brightness == Brightness.dark
        ? _darkPrimary
        : _lightPrimary;
    final onPrimary = brightness == Brightness.dark
        ? _darkOnPrimary
        : _lightOnPrimary;
    final disabled = brightness == Brightness.dark
        ? _darkDisabled
        : _lightDisabled;

    return [
      (foreground: onSurface, background: base, label: 'primary on base'),
      (foreground: onSurface, background: surface, label: 'primary on surface'),
      (
        foreground: onSurface,
        background: ext.surfaceSunken,
        label: 'primary on sunken',
      ),
      (
        foreground: onSurfaceVariant,
        background: base,
        label: 'secondary on base',
      ),
      (
        foreground: onSurfaceVariant,
        background: surface,
        label: 'secondary on surface',
      ),
      (
        foreground: onSurfaceVariant,
        background: ext.surfaceSunken,
        label: 'secondary on sunken',
      ),
      (
        foreground: onPrimary,
        background: primary,
        label: 'onPrimary on primary',
      ),
      (
        foreground: ext.focusBorder,
        background: surface,
        label: 'focus on surface',
      ),
      (
        foreground: ext.focusBorder,
        background: ext.surfaceSunken,
        label: 'focus on sunken',
      ),
      (
        foreground: ext.onSuccess,
        background: ext.success,
        label: 'onSuccess on success',
      ),
      (
        foreground: ext.onWarning,
        background: ext.warning,
        label: 'onWarning on warning',
      ),
      (
        foreground: ext.onDanger,
        background: ext.danger,
        label: 'onDanger on danger',
      ),
      (
        foreground: ext.onHighlight,
        background: ext.highlight,
        label: 'onHighlight on highlight',
      ),
      (
        foreground: onSurface,
        background: ext.successContainer,
        label: 'primary on successContainer',
      ),
      (foreground: disabled, background: surface, label: 'disabled on surface'),
      (
        foreground: brightness == Brightness.dark
            ? _darkErrorOnSurface
            : _lightError,
        background: surface,
        label: 'error on surface',
      ),
    ];
  }
}
