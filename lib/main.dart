import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart' show setUrlStrategy, PathUrlStrategy;
import 'utils/error_handler.dart';
import 'widgets/loading_animation.dart';
import 'widgets/scroll_to_top.dart';
import 'widgets/optimized_lottie_widget.dart';
import 'navigation_bar.dart';
import 'sections/about_section.dart';
import 'sections/experience_section.dart';
// import 'sections/projects_section.dart'; // Disabled for now
import 'sections/education_section.dart';
import 'sections/contact_section.dart';
import 'sections/resume_section.dart';
import 'sections/hero_section.dart';
import 'sections/skills_section.dart';
import 'package:go_router/go_router.dart';
import 'widgets/animated_service_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'theme/colors.dart'; // Centralized theme colors
import 'package:url_launcher/url_launcher.dart'; // Added for email functionality

/// Entry point of the application.
///
/// Localization: Uses flutter_localizations and intl. Add more languages by providing ARB/JSON files and updating supportedLocales.
/// Analytics: Uses Google Analytics for web usage tracking.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize comprehensive error handling
  ErrorHandler.initialize();
  
  if (kIsWeb) {
    setUrlStrategy(PathUrlStrategy());
  }
  runApp(const PortfolioApp());
}

/// The root widget of the portfolio website, supporting light and dark mode, and advanced routing using go_router.
class PortfolioApp extends StatefulWidget {
  const PortfolioApp({super.key});

  @override
  State<PortfolioApp> createState() => _PortfolioAppState();
}

class _PortfolioAppState extends State<PortfolioApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  /// GoRouter configuration for the app.
  ///
  /// '/' routes to the consulting landing page (ConsultingHomePage).
  /// '/chandranshu' routes to the personal profile/portfolio (HomeScreen).
  /// '/ragini' routes to Ragini Singh's profile page (RaginiProfilePage).
  late final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => ConsultingHomePage(
          onToggleTheme: _toggleTheme,
          isDarkMode: _themeMode == ThemeMode.dark,
        ),
      ),
      GoRoute(
        path: '/chandranshu',
        builder: (context, state) => HomeScreen(
          onToggleTheme: _toggleTheme,
          isDarkMode: _themeMode == ThemeMode.dark,
          gradientColors: _themeMode == ThemeMode.dark
              ? [AppColorsDark.primary, AppColorsDark.secondary, AppColorsDark.tertiary]
              : [AppColorsLight.background, AppColorsLight.secondary, AppColorsLight.tertiary],
        ),
      ),
      GoRoute(
        path: '/ragini',
        builder: (context, state) => const RaginiProfilePage(),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Chandranshu Singh | Portfolio',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
      builder: (context, child) {
        if (child == null) return const LoadingAnimation();
        return child;
      },
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColorsLight.primary,
        colorScheme: ColorScheme.light(
          primary: AppColorsLight.primary,
          secondary: AppColorsLight.secondary,
          surface: AppColorsLight.surface,
        ),
        scaffoldBackgroundColor: AppColorsLight.background,
        textTheme: TextTheme(
          displayLarge: GoogleFonts.playfairDisplay(
            fontSize: 44,
            fontWeight: FontWeight.bold,
            color: AppColorsLight.primary,
            letterSpacing: 1.3,
          ),
          displayMedium: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColorsLight.primary,
            letterSpacing: 1.1,
          ),
          titleLarge: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColorsLight.primary,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 18,
            color: AppColorsLight.primary,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 16,
            color: AppColorsLight.primary,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColorsLight.primary,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColorsDark.primary,
        colorScheme: ColorScheme.dark(
          primary: AppColorsDark.primary,
          secondary: AppColorsDark.secondary,
          surface: AppColorsDark.surface,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        drawerTheme: DrawerThemeData(
          backgroundColor: AppColorsDark.background,
          scrimColor: Colors.black54,
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.playfairDisplay(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
          displayMedium: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.1,
          ),
          titleLarge: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 18,
            color: Colors.white,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColorsDark.primary.withAlpha((204 * 255).round()),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}

/// The initial home screen of the portfolio website.
class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;
  final List<Color> gradientColors;
  const HomeScreen({super.key, required this.onToggleTheme, required this.isDarkMode, required this.gradientColors});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final aboutKey = GlobalKey();
  final experienceKey = GlobalKey();
  final projectsKey = GlobalKey();
  final educationKey = GlobalKey();
  final contactKey = GlobalKey();
  final resumeKey = GlobalKey();
  final skillsKey = GlobalKey();

  /// Scrolls smoothly to the widget associated with the given key.
  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Callback map for navigation items (getter so it can access instance members)
  Map<String, VoidCallback> get _navCallbacks => {
    'About': () => _scrollToSection(aboutKey),
    'Experience': () => _scrollToSection(experienceKey),
    'Education': () => _scrollToSection(educationKey),
    'Skills': () => _scrollToSection(skillsKey),
    'Resume': () => _scrollToSection(resumeKey),
    'Contact': () => _scrollToSection(contactKey),
  };

  @override
  void dispose() {
    // Dispose the ScrollController to prevent memory leaks
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 800;
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    return Container(
      decoration: isDarkMode
          ? const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color(0xFF9A67EA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            )
          : BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.gradientColors,
              ),
            ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // Use the posh, glassmorphic NavigationBarWidget
        appBar: NavigationBarWidget(
          navCallbacks: _navCallbacks,
          onToggleTheme: widget.onToggleTheme,
          isDarkMode: widget.isDarkMode,
        ),
        // Use the improved navigation drawer for mobile
        drawer: isSmallScreen
            ? NavigationDrawerWidget(
                navCallbacks: _navCallbacks,
                onToggleTheme: widget.onToggleTheme,
                isDarkMode: widget.isDarkMode,
              )
            : null,
        floatingActionButton: ScrollToTopButton(
          scrollController: _scrollController,
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: Column(
            children: [
              // Hero section
              ErrorHandler.errorBoundary(
                errorContext: 'HeroSection',
                child: HeroSection(
                  scrollController: _scrollController,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // About Section
              Container(
                key: aboutKey,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ErrorHandler.errorBoundary(
                  errorContext: 'AboutSection',
                  child: AboutSection(scrollController: _scrollController),
                ),
              ),
              
              // Experience Section
              Container(
                key: experienceKey,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ErrorHandler.errorBoundary(
                  errorContext: 'ExperienceSection',
                  child: ExperienceSection(scrollController: _scrollController),
                ),
              ),
              
              // Skills Section
              Container(
                key: skillsKey,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ErrorHandler.errorBoundary(
                  errorContext: 'SkillsSection',
                  child: SkillsSection(scrollController: _scrollController),
                ),
              ),
              
              // Education Section
              Container(
                key: educationKey,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ErrorHandler.errorBoundary(
                  errorContext: 'EducationSection',
                  child: EducationSection(scrollController: _scrollController),
                ),
              ),
              
              // Contact Section
              Container(
                key: contactKey,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ErrorHandler.errorBoundary(
                  errorContext: 'ContactSection',
                  child: ContactSection(scrollController: _scrollController),
                ),
              ),
              
              // Resume Section
              Container(
                key: resumeKey,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ErrorHandler.errorBoundary(
                  errorContext: 'ResumeSection',
                  child: ResumeSection(scrollController: _scrollController),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom 404 Not Found Page for web
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 24),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
              child: Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ConsultingHomePage is the new landing page for consulting services.
///
/// This page features animated service cards for IT Consulting, Digital Product Design, and AI/VR Application Services.
/// It also provides a prominent link to the profile/portfolio at /chandranshu/.
class ConsultingHomePage extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode; // This prop is for the theme toggle button state
  const ConsultingHomePage({super.key, required this.onToggleTheme, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Determine dark mode status directly from the current theme context for styling
    final bool actualDarkMode = theme.brightness == Brightness.dark;

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;
    final cardSpacing = isMobile ? 24.0 : 40.0;
    final cardWidth = isMobile ? double.infinity : 340.0;
    final cardList = [
      AnimatedServiceCard(
        title: 'IT Consulting',
        description: 'Expert guidance for digital transformation, cloud, security, and scalable IT solutions.',
        lottieAsset: 'assets/lottie/it_consulting.json',
        color: theme.colorScheme.surface,
      ),
      AnimatedServiceCard(
        title: 'Digital Product Design',
        description: 'Elegant UI/UX, rapid prototyping, and end-to-end product design for web, mobile, and XR.',
        lottieAsset: 'assets/lottie/product_management.json',
        color: theme.colorScheme.surface,
      ),
      AnimatedServiceCard(
        title: 'AI & Augmented Reality',
        description: 'AI-driven apps, machine learning, and immersive AR/VR experiences for the future.',
        lottieAsset: 'assets/lottie/ai.json',
        color: theme.colorScheme.surface,
      ),
    ];

    // Define text styles using actualDarkMode for color decisions
    final TextStyle? titleStyle = theme.textTheme.displayLarge?.copyWith(
      fontWeight: FontWeight.bold,
      color: actualDarkMode ? Colors.white : theme.colorScheme.primary,
      letterSpacing: 1.4,
      fontSize: isMobile ? 32 : 44,
      fontFamily: GoogleFonts.playfairDisplay().fontFamily,
    );

    final TextStyle? taglineStyle = theme.textTheme.titleLarge?.copyWith(
      color: actualDarkMode ? Colors.white.withValues(alpha: 0.85) : theme.colorScheme.secondary,
      fontWeight: FontWeight.w600,
      fontSize: isMobile ? 18 : 22,
      letterSpacing: 1.1,
      fontFamily: GoogleFonts.inter().fontFamily,
    );
    
    final String contactEmail = "contact@techknowtrees.com";

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary.withAlpha((0.96 * 255).round()),
        elevation: 0,
        title: Text(
          'Tech Know Trees',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white, // AppBar title color is always white for contrast
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: isMobile ? 20 : 28,
            fontFamily: GoogleFonts.playfairDisplay().fontFamily,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        centerTitle: true,
        actions: [
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Semantics(
                label: 'People dropdown menu',
                button: true,
                child: FocusTraversalGroup(
                  child: PopupMenuButton<String>(
                    tooltip: 'Select profile',
                    offset: const Offset(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    color: theme.cardColor,
                    elevation: 10,
                    onSelected: (String value) {
                      if (value == 'Chandranshu Singh') {
                        GoRouter.of(context).go('/chandranshu');
                      } else if (value == 'Ragini Singh') {
                        GoRouter.of(context).go('/ragini');
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'Chandranshu Singh',
                        child: Row(
                          children: [
                            const Icon(Icons.account_circle_rounded, color: Colors.deepPurpleAccent, size: 22),
                            const SizedBox(width: 10),
                            Text('Chandranshu Singh', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'Ragini Singh',
                        child: Row(
                          children: [
                            const Icon(Icons.account_circle_rounded, color: Colors.teal, size: 22),
                            const SizedBox(width: 10),
                            Text('Ragini Singh', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.secondary.withAlpha(30),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.people, color: theme.colorScheme.secondary, size: 22),
                            const SizedBox(width: 8),
                            Text('People', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: theme.colorScheme.secondary)),
                            const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          IconButton(
            // Use isDarkMode (the direct prop) for the toggle icon state
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: onToggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: isMobile ? Drawer(
        child: SafeArea(
          child: Column(
            children: [
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
                ),
                child: Center(
                  child: Text(
                    'Tech Know Trees',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.account_circle_rounded, color: Colors.deepPurpleAccent),
                title: Text('Chandranshu Singh', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  GoRouter.of(context).go('/chandranshu');
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_circle_rounded, color: Colors.teal),
                title: Text('Ragini Singh', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  GoRouter.of(context).go('/ragini');
                },
              ),
              const Spacer(),
              ListTile(
                // Use isDarkMode (the direct prop) for the toggle icon state in the drawer
                leading: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                title: Text(isDarkMode ? 'Light Mode' : 'Dark Mode', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                onTap: onToggleTheme,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ) : null,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.18,
                child: LottieWidgets.background(
                  assetPath: 'assets/lottie/bg_abstract.json',
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 56 : 96,
                    horizontal: isMobile ? 18 : 48,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: actualDarkMode
                          ? [theme.colorScheme.primary, theme.colorScheme.secondary.withAlpha((0.7 * 255).round())]
                          : [theme.colorScheme.surface, theme.colorScheme.secondary.withAlpha((0.18 * 255).round())],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: isMobile ? 160 : 220,
                        child: LottieWidgets.serviceCard(
                          assetPath: 'assets/lottie/tech_know_trees.json',
                          size: isMobile ? 160 : 220,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Empowering Digital Transformation',
                        style: titleStyle, 
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'IT Consulting, Product Design, AI Solutions',
                        style: taglineStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 32 : 64,
                    horizontal: isMobile ? 12 : 48,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (isMobile) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int i = 0; i < cardList.length; i++) ...[
                              if (i > 0) const SizedBox(height: 20),
                              cardList[i]
                                .animate()
                                .fadeIn(duration: 600.ms, delay: (i * 120).ms)
                                .slideY(begin: 0.18, end: 0, duration: 600.ms, delay: (i * 120).ms),
                            ],
                          ],
                        );
                      } else {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 0; i < cardList.length; i++) ...[
                                SizedBox(
                                  width: cardWidth,
                                  child: cardList[i]
                                    .animate()
                                    .fadeIn(duration: 600.ms, delay: (i * 120).ms)
                                    .slideY(begin: 0.18, end: 0, duration: 600.ms, delay: (i * 120).ms),
                                ),
                                if (i != cardList.length - 1)
                                  SizedBox(width: cardSpacing),
                              ],
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.18, end: 0, duration: 600.ms),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  color: actualDarkMode ? Colors.black.withValues(alpha: 0.4) : theme.colorScheme.surface.withValues(alpha: 0.8),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Get in Touch',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: actualDarkMode ? Colors.white.withValues(alpha: 0.9) : theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final Uri emailUri = Uri(scheme: 'mailto', path: contactEmail, query: 'subject=Inquiry from TechKnowTrees Website&body=Hello Tech Know Trees team,\n\nI am interested in learning more about your services.\n\nBest regards,');
                            try {
                              if (await canLaunchUrl(emailUri)) {
                                await launchUrl(emailUri);
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Could not open email client. Please contact us directly at $contactEmail')),
                                  );
                                }
                              }
                            } catch (e) {
                               if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error launching email: Please check your email client setup.')),
                                );
                              }
                            }
                          },
                          child: Text(
                            contactEmail,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: actualDarkMode ? Colors.white.withValues(alpha: 0.85) : theme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: actualDarkMode ? Colors.white.withValues(alpha: 0.85) : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '© ${DateTime.now().year} Tech Know Trees. All rights reserved.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: actualDarkMode ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Add the RaginiProfilePage widget at the end of the file
class RaginiProfilePage extends StatelessWidget {
  const RaginiProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ragini Singh'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Center(
        child: Text(
          'Ragini Singh\'s Profile (Coming Soon)',
          style: theme.textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Main entry point for the Tech Know Trees portfolio website.
///
/// This file sets up the app, theming, routing, and the main home/profile pages.
///
/// - Uses go_router for advanced routing.
/// - Centralizes theming with ThemeExtension and color classes.
/// - Implements accessibility, performance, and posh UI/UX best practices.
