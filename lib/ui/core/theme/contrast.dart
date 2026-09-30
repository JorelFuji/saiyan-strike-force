import 'dart:math' as math;

import 'package:flutter/material.dart';

/// WCAG 2.x contrast ratio between [foreground] and [background] (sRGB).
double contrastRatio(Color foreground, Color background) {
  final fg = _relativeLuminance(foreground);
  final bg = _relativeLuminance(background);
  final lighter = math.max(fg, bg);
  final darker = math.min(fg, bg);
  return (lighter + 0.05) / (darker + 0.05);
}

double _relativeLuminance(Color color) {
  double channel(int value) {
    final c = value / 255.0;
    if (c <= 0.03928) {
      return c / 12.92;
    }
    return math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = channel((color.r * 255.0).round());
  final g = channel((color.g * 255.0).round());
  final b = channel((color.b * 255.0).round());
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}
