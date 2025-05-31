import 'package:flutter/material.dart';

/// Centralized color and theme constants for Tech Know Trees portfolio
///
/// This file defines all color constants for both light and dark themes.

/// Light theme colors
class AppColorsLight {
  static const Color primary = Color(0xFF1A2340); // Deep posh blue
  static const Color secondary = Color(0xFF1EC6B6); // Emerald/teal accent
  static const Color surface = Color(0xFFF7F8FA); // Light background
  static const Color background = Color(0xFFF7F8FA);
  static const Color error = Color(0xFFD32F2F);
  static const Color tertiary = Color(0xFF3F8EFC); // Vibrant blue for gradients
  // Add more as needed
}

/// Dark theme colors
class AppColorsDark {
  static const Color primary = Color(0xFF12131A); // Deep, rich blue-black
  static const Color secondary = Color(0xFF9A67EA); // Elegant purple accent
  static const Color surface = Color(0xFF12131A); // Same as background for now
  static const Color background = Color(0xFF12131A);
  static const Color error = Color(0xFFD32F2F);
  static const Color tertiary = Color(0xFF3F8EFC); // Posh blue accent for gradients
  // Gradient for dark mode backgrounds
  static const Gradient backgroundGradient = LinearGradient(
    colors: [Colors.black, Color(0xFF9A67EA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  // Add more as needed
}

/// Theme extension for custom gradients and shadows
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Gradient? heroGradient;
  final List<BoxShadow>? cardShadows;
  final double? cardBorderRadius;
  final Duration? animationDuration;

  const AppThemeExtension({
    this.heroGradient,
    this.cardShadows,
    this.cardBorderRadius,
    this.animationDuration,
  });

  @override
  AppThemeExtension copyWith({
    Gradient? heroGradient,
    List<BoxShadow>? cardShadows,
    double? cardBorderRadius,
    Duration? animationDuration,
  }) {
    return AppThemeExtension(
      heroGradient: heroGradient ?? this.heroGradient,
      cardShadows: cardShadows ?? this.cardShadows,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      heroGradient: Gradient.lerp(heroGradient, other.heroGradient, t),
      cardShadows: BoxShadow.lerpList(cardShadows, other.cardShadows, t),
      cardBorderRadius: (cardBorderRadius ?? 0) + ((other.cardBorderRadius ?? 0) - (cardBorderRadius ?? 0)) * t,
      animationDuration: animationDuration == null || other.animationDuration == null
          ? animationDuration ?? other.animationDuration
          : Duration(milliseconds: (animationDuration!.inMilliseconds + ((other.animationDuration!.inMilliseconds - animationDuration!.inMilliseconds) * t).round())),
    );
  }

  // Light and dark presets
  static const AppThemeExtension light = AppThemeExtension(
    heroGradient: LinearGradient(
      colors: [AppColorsLight.primary, AppColorsLight.secondary, AppColorsLight.tertiary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardShadows: [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 16,
        offset: Offset(0, 8),
      ),
    ],
    cardBorderRadius: 16.0,
    animationDuration: Duration(milliseconds: 300),
  );

  static const AppThemeExtension dark = AppThemeExtension(
    heroGradient: LinearGradient(
      colors: [AppColorsDark.primary, AppColorsDark.secondary, AppColorsDark.tertiary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardShadows: [
      BoxShadow(
        color: Color(0x33000000),
        blurRadius: 24,
        offset: Offset(0, 10),
      ),
    ],
    cardBorderRadius: 16.0,
    animationDuration: Duration(milliseconds: 300),
  );
}

/// Usage:
/// Theme.of(context).extension<AppThemeExtension>()?.heroGradient
/// Theme.of(context).extension<AppThemeExtension>()?.cardBorderRadius
/// Theme.of(context).extension<AppThemeExtension>()?.animationDuration 