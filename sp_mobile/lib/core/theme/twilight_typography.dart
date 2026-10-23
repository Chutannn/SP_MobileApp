import 'package:flutter/material.dart';
import 'twilight_palette.dart';

/// Typography helpers following the "Twilight Stillness Mobile" design system.
class TwilightTypography {
  const TwilightTypography._();

  static TextStyle serif({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color color = TwilightPalette.onSurface,
    double? height,
  }) {
    return TextStyle(
      fontFamily: 'Georgia',
      fontFamilyFallback: const ['Lora', 'serif'],
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height ?? 1.25,
      letterSpacing: 0.2,
    );
  }

  static TextStyle sans({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color color = TwilightPalette.onSurface,
    double letterSpacing = 0.2,
    double? height,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height ?? 1.45,
    );
  }
}
