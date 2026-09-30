import 'package:flutter/material.dart';

/// Semantic values that [ColorScheme] does not model (sunken surface, shadows,
/// state containers, focus ring).
@immutable
final class VulcanColors extends ThemeExtension<VulcanColors> {
  const VulcanColors({
    required this.surfaceSunken,
    required this.shadowDark,
    required this.shadowLight,
    required this.primaryDeep,
    required this.focusBorder,
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.danger,
    required this.onDanger,
    required this.dangerContainer,
    required this.highlight,
    required this.onHighlight,
    required this.highlightContainer,
  });

  final Color surfaceSunken;
  final Color shadowDark;
  final Color shadowLight;
  final Color primaryDeep;
  final Color focusBorder;
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color danger;
  final Color onDanger;
  final Color dangerContainer;
  final Color highlight;
  final Color onHighlight;
  final Color highlightContainer;

  static const dark = VulcanColors(
    surfaceSunken: Color(0xFF1C1A19),
    shadowDark: Color(0xFF141312),
    shadowLight: Color(0xFF302D2B),
    primaryDeep: Color(0xFF5E81AC),
    focusBorder: Color(0xFF88C0D0),
    success: Color(0xFFA3BE8C),
    onSuccess: Color(0xFF12181B),
    successContainer: Color(0xFF3D4A35),
    warning: Color(0xFFEBCB8B),
    onWarning: Color(0xFF12181B),
    warningContainer: Color(0xFF4A4030),
    danger: Color(0xFF9A3F48),
    onDanger: Color(0xFFFFFFFF),
    dangerContainer: Color(0xFF4A2E32),
    highlight: Color(0xFFD08770),
    onHighlight: Color(0xFF12181B),
    highlightContainer: Color(0xFF4A352E),
  );

  static const light = VulcanColors(
    surfaceSunken: Color(0xFFD8DEE9),
    shadowDark: Color(0xFFB8C0CC),
    shadowLight: Color(0xFFFFFFFF),
    primaryDeep: Color(0xFF3B5B7F),
    focusBorder: Color(0xFF3B5B7F),
    success: Color(0xFF5E7A4A),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFD8E8CC),
    warning: Color(0xFF8A6B2E),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFF5E6BC),
    danger: Color(0xFF9E3A42),
    onDanger: Color(0xFFFFFFFF),
    dangerContainer: Color(0xFFF0D4D6),
    highlight: Color(0xFF9E5038),
    onHighlight: Color(0xFFFFFFFF),
    highlightContainer: Color(0xFFF0D8CE),
  );

  @override
  VulcanColors copyWith({
    Color? surfaceSunken,
    Color? shadowDark,
    Color? shadowLight,
    Color? primaryDeep,
    Color? focusBorder,
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? danger,
    Color? onDanger,
    Color? dangerContainer,
    Color? highlight,
    Color? onHighlight,
    Color? highlightContainer,
  }) {
    return VulcanColors(
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      shadowDark: shadowDark ?? this.shadowDark,
      shadowLight: shadowLight ?? this.shadowLight,
      primaryDeep: primaryDeep ?? this.primaryDeep,
      focusBorder: focusBorder ?? this.focusBorder,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      highlight: highlight ?? this.highlight,
      onHighlight: onHighlight ?? this.onHighlight,
      highlightContainer: highlightContainer ?? this.highlightContainer,
    );
  }

  @override
  VulcanColors lerp(ThemeExtension<VulcanColors>? other, double t) {
    if (other is! VulcanColors) {
      return this;
    }
    return VulcanColors(
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      shadowDark: Color.lerp(shadowDark, other.shadowDark, t)!,
      shadowLight: Color.lerp(shadowLight, other.shadowLight, t)!,
      primaryDeep: Color.lerp(primaryDeep, other.primaryDeep, t)!,
      focusBorder: Color.lerp(focusBorder, other.focusBorder, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      danger: Color.lerp(danger, other.danger, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      onHighlight: Color.lerp(onHighlight, other.onHighlight, t)!,
      highlightContainer: Color.lerp(
        highlightContainer,
        other.highlightContainer,
        t,
      )!,
    );
  }
}

extension VulcanColorsBuildContext on BuildContext {
  VulcanColors get vulcanColors =>
      Theme.of(this).extension<VulcanColors>() ?? VulcanColors.dark;
}
