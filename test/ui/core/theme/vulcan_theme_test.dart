import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/ui/core/theme/contrast.dart';
import 'package:vulcan_fitness/ui/core/theme/vulcan_colors.dart';
import 'package:vulcan_fitness/ui/core/theme/vulcan_theme.dart';

void main() {
  group('contrast acceptance', () {
    for (final brightness in [Brightness.light, Brightness.dark]) {
      group('${brightness.name} mode', () {
        for (final pair in VulcanTheme.contrastPairs(brightness)) {
          test('${pair.label} meets threshold', () {
            final ratio = contrastRatio(pair.foreground, pair.background);
            final isLargeOrNonText =
                pair.label.contains('focus') ||
                pair.label.contains('onSuccess') ||
                pair.label.contains('onWarning') ||
                pair.label.contains('onDanger') ||
                pair.label.contains('onHighlight');
            final minimum = isLargeOrNonText ? 3.0 : 4.5;
            expect(
              ratio,
              greaterThanOrEqualTo(minimum),
              reason:
                  '${pair.label}: ${ratio.toStringAsFixed(2)}:1 '
                  '(need ≥$minimum:1)',
            );
          });
        }
      });
    }
  });

  group('VulcanColors extension', () {
    test('copyWith replaces provided fields only', () {
      const original = VulcanColors.dark;
      final updated = original.copyWith(focusBorder: const Color(0xFFFFFFFF));
      expect(updated.focusBorder, const Color(0xFFFFFFFF));
      expect(updated.surfaceSunken, original.surfaceSunken);
    });

    test('lerp interpolates between light and dark', () {
      const a = VulcanColors.dark;
      const b = VulcanColors.light;
      final mid = a.lerp(b, 0.5);
      expect(mid.surfaceSunken, isNot(equals(a.surfaceSunken)));
      expect(mid.surfaceSunken, isNot(equals(b.surfaceSunken)));
    });
  });

  group('typography', () {
    test('uses Manrope with documented weights', () {
      final light = VulcanTheme.light();
      expect(light.textTheme.displayLarge?.fontFamily, VulcanTheme.fontFamily);
      expect(light.textTheme.displayLarge?.fontWeight, FontWeight.w800);
      expect(light.textTheme.headlineMedium?.fontWeight, FontWeight.w700);
      expect(light.textTheme.bodyLarge?.fontWeight, FontWeight.w500);
    });

    test('stat and timer styles use tabular figures', () {
      final stat = VulcanTheme.statStyle(Brightness.light);
      final timer = VulcanTheme.timerStyle(Brightness.light);
      expect(stat.fontFeatures, contains(const FontFeature.tabularFigures()));
      expect(timer.fontFeatures, contains(const FontFeature.tabularFigures()));
      expect(VulcanTheme.light().textTheme.titleLarge?.fontFeatures, isNotNull);
    });
  });

  group('component defaults', () {
    test('buttons and icon buttons meet 48dp minimum', () {
      final theme = VulcanTheme.light();
      final filled = theme.filledButtonTheme.style;
      expect(filled?.minimumSize?.resolve({}), const Size(48, 48));
      final icon = theme.iconButtonTheme.style;
      expect(icon?.minimumSize?.resolve({}), const Size(48, 48));
    });

    test('filled button disabled label uses onSurface not onPrimary', () {
      final theme = VulcanTheme.light();
      final style = theme.filledButtonTheme.style!;
      final disabledFg = style.foregroundColor?.resolve({WidgetState.disabled});
      expect(disabledFg, theme.colorScheme.onSurface.withValues(alpha: 0.38));
      final enabledFg = style.foregroundColor?.resolve({});
      expect(enabledFg, theme.colorScheme.onPrimary);
    });

    test('input focus uses visible border width', () {
      final theme = VulcanTheme.light();
      final focused = theme.inputDecorationTheme.focusedBorder;
      expect(focused, isA<OutlineInputBorder>());
      final border = focused! as OutlineInputBorder;
      expect(border.borderSide.width, 2);
    });

    test('themes attach VulcanColors', () {
      expect(VulcanTheme.light().extension<VulcanColors>(), VulcanColors.light);
      expect(VulcanTheme.dark().extension<VulcanColors>(), VulcanColors.dark);
    });

    test('documented surface tokens', () {
      expect(
        VulcanTheme.light().scaffoldBackgroundColor,
        const Color(0xFFECEFF4),
      );
      expect(VulcanTheme.light().colorScheme.surface, const Color(0xFFE5E9F0));
      expect(
        VulcanTheme.light().extension<VulcanColors>()!.surfaceSunken,
        const Color(0xFFD8DEE9),
      );
      expect(
        VulcanTheme.dark().scaffoldBackgroundColor,
        const Color(0xFF22201F),
      );
    });
  });
}
