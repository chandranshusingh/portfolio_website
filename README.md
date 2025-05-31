# profile_resume

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## THEMING

This project uses centralized theme management in `lib/theme/colors.dart` and a custom `ThemeExtension` (`AppThemeExtension`) for scalable theming.

### Color Structure
- All color constants for light and dark mode are defined in `AppColorsLight` and `AppColorsDark`.
- Use these constants for all color assignments in your widgets and themes.

### Custom ThemeExtension
- `AppThemeExtension` provides custom gradients and card shadows for both light and dark themes.
- Access the extension anywhere in your widget tree:

```dart
final heroGradient = Theme.of(context).extension<AppThemeExtension>()?.heroGradient;
final cardShadows = Theme.of(context).extension<AppThemeExtension>()?.cardShadows;
```

### Adding More Design Tokens
- Extend `AppThemeExtension` with more fields (e.g., border radii, animation durations) as needed.

### Example: Using a Gradient
```dart
Container(
  decoration: BoxDecoration(
    gradient: Theme.of(context).extension<AppThemeExtension>()?.heroGradient,
  ),
  child: ...,
)
```

### Best Practices
- Always use the centralized theme and extension for consistency and maintainability.
- Update both light and dark presets when adding new fields to the extension.
