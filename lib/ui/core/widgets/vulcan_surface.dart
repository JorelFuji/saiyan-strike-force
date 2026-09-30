import 'package:flutter/material.dart';

import '../theme/vulcan_colors.dart';
import '../theme/vulcan_theme.dart';

/// Selective soft primary surface with directional shadows and a real border.
class VulcanSurface extends StatefulWidget {
  const VulcanSurface({
    required this.child,
    this.onTap,
    this.semanticsLabel,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  static const Duration _pressDuration = Duration(milliseconds: 110);

  @override
  State<VulcanSurface> createState() => _VulcanSurfaceState();
}

class _VulcanSurfaceState extends State<VulcanSurface> {
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final vulcan = context.vulcanColors;
    final colorScheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final pressed = widget.onTap != null && _pressed;

    final decoration = _decoration(
      vulcan: vulcan,
      colorScheme: colorScheme,
      pressed: pressed,
      focused: _focused,
    );

    Widget content = AnimatedScale(
      scale: pressed && !reduceMotion ? 0.97 : 1,
      duration: reduceMotion ? Duration.zero : VulcanSurface._pressDuration,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: reduceMotion ? Duration.zero : VulcanSurface._pressDuration,
        curve: Curves.easeOut,
        decoration: decoration,
        padding: const EdgeInsets.all(16),
        child: widget.child,
      ),
    );

    if (widget.onTap != null) {
      content = Focus(
        onFocusChange: (focused) => setState(() => _focused = focused),
        child: Semantics(
          button: true,
          label: widget.semanticsLabel,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: widget.onTap,
              onHighlightChanged: (highlight) {
                setState(() => _pressed = highlight);
              },
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(VulcanTheme.radiusCard),
              ),
              child: content,
            ),
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: content,
    );
  }

  BoxDecoration _decoration({
    required VulcanColors vulcan,
    required ColorScheme colorScheme,
    required bool pressed,
    required bool focused,
  }) {
    final baseColor = colorScheme.surface;
    final borderColor = focused
        ? vulcan.focusBorder
        : colorScheme.outlineVariant.withValues(alpha: 0.6);
    final borderWidth = focused ? 2.0 : 1.0;

    if (pressed) {
      return BoxDecoration(
        color: vulcan.surfaceSunken,
        borderRadius: BorderRadius.circular(VulcanTheme.radiusCard),
        border: Border.all(color: vulcan.primaryDeep, width: 2),
        boxShadow: [
          BoxShadow(
            color: vulcan.shadowDark.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      );
    }

    return BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(VulcanTheme.radiusCard),
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: [
        BoxShadow(
          color: vulcan.shadowLight.withValues(alpha: 0.4),
          blurRadius: 14,
          offset: const Offset(-6, -6),
        ),
        BoxShadow(
          color: vulcan.shadowDark.withValues(alpha: 0.4),
          blurRadius: 14,
          offset: const Offset(6, 6),
        ),
      ],
    );
  }
}
