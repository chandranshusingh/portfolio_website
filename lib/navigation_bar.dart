import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

/// A responsive, posh navigation bar with glassmorphism, smooth transitions, and accessibility improvements.
///
/// - On consulting home page ('/'): shows only the 'Chandranshu Singh' link (routes to /chandranshu/).
/// - On profile page ('/chandranshu/'): shows full section navigation (About, Experience, etc.).
/// - Applies glassmorphism: background blur, semi-transparent color, and subtle shadow.
/// - Ensures elegant appearance in both light and dark modes.
/// - Adds smooth transitions for theme changes.
/// - Improves title font, spacing, and shadow for a posh look.
/// - Adds tooltips to navigation items for accessibility.
/// - Ensures all navigation items are present and styled consistently.
/// - Well-documented for maintainability.
class NavigationBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Map<String, VoidCallback> navCallbacks;
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const NavigationBarWidget({
    super.key,
    required this.navCallbacks,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 800;
    final navItems = [
      {'label': 'About', 'onTap': navCallbacks['About']},
      {'label': 'Experience', 'onTap': navCallbacks['Experience']},
      {'label': 'Skills', 'onTap': navCallbacks['Skills']},
      {'label': 'Education', 'onTap': navCallbacks['Education']},
      {'label': 'Contact', 'onTap': navCallbacks['Contact']},
      {'label': 'Resume', 'onTap': navCallbacks['Resume']},
    ];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: AppBar(
            elevation: 12,
            automaticallyImplyLeading: false,
            backgroundColor: theme.brightness == Brightness.dark
                ? Colors.black.withAlpha((0.55 * 255).round())
                : Colors.white.withAlpha((0.38 * 255).round()),
            shadowColor: theme.brightness == Brightness.dark
                ? Colors.black.withAlpha((0.22 * 255).round())
                : Colors.black.withAlpha((0.10 * 255).round()),
            title: isSmallScreen
                ? Text(
                    'Tech Know Trees',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.brightness == Brightness.dark ? Colors.white : theme.colorScheme.primary,
                      letterSpacing: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 350),
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: theme.brightness == Brightness.dark ? Colors.white : theme.colorScheme.primary,
                              letterSpacing: 2.0,
                              shadows: [
                                Shadow(
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.black.withAlpha((0.45 * 255).round())
                                      : Colors.white.withAlpha((0.25 * 255).round()),
                                  offset: const Offset(0, 2),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Text(
                              'Tech Know Trees',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            centerTitle: true,
            leading: isSmallScreen
                ? Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu_rounded),
                      tooltip: 'Open navigation menu',
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  )
                : null,
            actions: isSmallScreen
                ? []
                : [
                    ...navItems.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Tooltip(
                            message: item['label'] as String,
                            waitDuration: const Duration(milliseconds: 300),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                splashColor: theme.colorScheme.secondary.withAlpha((0.18 * 255).round()),
                                highlightColor: theme.colorScheme.secondary.withAlpha((0.10 * 255).round()),
                                onTap: item['onTap'] as VoidCallback?,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    color: theme.brightness == Brightness.dark
                                        ? Colors.white.withAlpha((0.09 * 255).round())
                                        : theme.colorScheme.secondary.withAlpha((0.13 * 255).round()),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.brightness == Brightness.dark
                                            ? Colors.black.withAlpha((0.13 * 255).round())
                                            : Colors.black.withAlpha((0.08 * 255).round()),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    item['label'] as String,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: theme.brightness == Brightness.dark ? Colors.white : theme.colorScheme.primary,
                                      letterSpacing: 0.8,
                                      shadows: theme.brightness == Brightness.dark
                                          ? [Shadow(color: Colors.black.withAlpha((0.25 * 255).round()), offset: Offset(0, 1), blurRadius: 4)]
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )),
                    IconButton(
                      icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                      tooltip: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
                      onPressed: onToggleTheme,
                    ),
                  ],
            iconTheme: IconThemeData(
              color: theme.brightness == Brightness.dark 
                  ? Colors.white 
                  : theme.colorScheme.primary,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

/// Navigation drawer for mobile view with posh glassmorphism, elegant transitions, and accessibility improvements.
///
/// - Matches the glassmorphism style of the navigation bar.
/// - Improved header and item styling for elegance and accessibility.
/// - Adds tooltips and a clear theme toggle.
/// - Well-documented for maintainability.
class NavigationDrawerWidget extends StatelessWidget {
  final Map<String, VoidCallback> navCallbacks;
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const NavigationDrawerWidget({
    super.key,
    required this.navCallbacks,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Drawer(
            backgroundColor: theme.brightness == Brightness.dark
                ? Colors.black.withAlpha((0.65 * 255).round())
                : Colors.white.withAlpha((0.38 * 255).round()),
            child: SafeArea(
              child: Column(
                children: [
                  // Elegant header with gradient and shadow
                  DrawerHeader(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.18 * 255).round()),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Chandranshu Singh',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withAlpha((0.35 * 255).round()),
                              offset: const Offset(0, 2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Navigation items
                  if (GoRouterState.of(context).uri.toString() == '/')
                    Tooltip(
                      message: 'Chandranshu Singh',
                      waitDuration: const Duration(milliseconds: 300),
                      child: ListTile(
                        leading: const Icon(Icons.account_circle_rounded),
                        title: const Text('Chandranshu Singh'),
                        onTap: () {
                          Navigator.pop(context);
                          GoRouter.of(context).go('/chandranshu');
                        },
                      ),
                    )
                  else
                    ...[
                      for (final entry in navCallbacks.entries)
                        Tooltip(
                          message: entry.key,
                          waitDuration: const Duration(milliseconds: 300),
                          child: ListTile(
                            title: Text(
                              entry.key,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: theme.brightness == Brightness.dark ? Colors.white : theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              entry.value();
                            },
                          ),
                        ),
                    ],
                  const Spacer(),
                  // Prominent dark mode toggle (since it's removed from app bar in mobile)
                  const Divider(),
                  Tooltip(
                    message: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                    waitDuration: const Duration(milliseconds: 300),
                    child: ListTile(
                      leading: Icon(
                        isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: theme.brightness == Brightness.dark ? Colors.white : theme.iconTheme.color,
                      ),
                      title: Text(
                        isDarkMode ? 'Light Mode' : 'Dark Mode',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: theme.brightness == Brightness.dark ? Colors.white : theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context); // Close drawer first
                        onToggleTheme(); // Then toggle theme
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 