# Theming Guide for Tech Know Trees Portfolio

This document explains the theming architecture, how to use and extend the theme, and best practices for maintaining a posh, professional, and accessible UI.

## Centralized Color Management
- All color constants are defined in `lib/theme/colors.dart`.
- Use `AppColorsLight` and `AppColorsDark` for all color assignments.

## Custom ThemeExtension
- `AppThemeExtension` provides custom gradients, card shadows, card border radius, and animation duration for both light and dark themes.
- Integrated into `ThemeData.extensions` in `main.dart`.

### Accessing Custom Theme Values
```dart
final heroGradient = Theme.of(context).extension<AppThemeExtension>()?.heroGradient;
final cardShadows = Theme.of(context).extension<AppThemeExtension>()?.cardShadows;
final borderRadius = Theme.of(context).extension<AppThemeExtension>()?.cardBorderRadius ?? 12.0;
final duration = Theme.of(context).extension<AppThemeExtension>()?.animationDuration ?? Duration(milliseconds: 200);
```

### Example: Using a Gradient and Border Radius
```dart
Container(
  decoration: BoxDecoration(
    gradient: Theme.of(context).extension<AppThemeExtension>()?.heroGradient,
    borderRadius: BorderRadius.circular(
      Theme.of(context).extension<AppThemeExtension>()?.cardBorderRadius ?? 12.0,
    ),
    boxShadow: Theme.of(context).extension<AppThemeExtension>()?.cardShadows,
  ),
  child: ...,
)
```

## Extending the Theme
- Add new fields to `AppThemeExtension` for additional design tokens (e.g., border radii, animation durations).
- Update both `light` and `dark` presets.
- Register the extension in both `ThemeData` objects in `main.dart`.
- Document new tokens in this file.

## Best Practices
- Always use the centralized theme and extension for consistency.
- Test new theme fields in both light and dark mode.
- Document any new tokens in this file.

## Accessibility & SEO
- Use semantic labels, tooltips, and ensure color contrast.
- Periodically audit with Lighthouse or axe DevTools.
- **Document audits:**
  - Add a section to your release notes or a dedicated `AUDIT.md` file.
  - Example:
    ```
    ## Accessibility Audit - v1.2.0
    - All interactive elements keyboard accessible: ✅
    - Color contrast meets WCAG AA: ✅
    - All images have alt/semantic labels: ✅
    - SEO meta tags present: ✅
    - Issues: None
    ```

## Onboarding New Contributors
- Point new contributors to this THEMING.md for a smooth start.
- Encourage documentation of any new design tokens or theme changes here.

---

For questions or contributions, see the README or contact the maintainers. 