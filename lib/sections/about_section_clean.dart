import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:math';
import '../utils/error_handler.dart';
import '../widgets/optimized_image_widget.dart';

/// About section of the portfolio website with slide-in and fade-in animation and posh style.
class AboutSection extends StatefulWidget {
  final ScrollController? scrollController;
  const AboutSection({super.key, this.scrollController});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> with TickerProviderStateMixin {
  double _opacity = 0.0;
  late AnimationController _controller;
  late AnimationController _particleController;
  final int _particleCount = 7;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    // Particle animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
    _particles = List.generate(_particleCount, (i) => _Particle.random());
  }

  @override
  void dispose() {
    ErrorHandler.safeDisposeControllers(
      [_controller, _particleController],
      names: ['AboutMainController', 'AboutParticleController'],
    );
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > 0.1 && _opacity == 0.0) {
      setState(() {
        _opacity = 1.0;
      });
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ErrorHandler.errorBoundary(
      errorContext: 'AboutSection',
      child: VisibilityDetector(
        key: const Key('about-section'),
        onVisibilityChanged: _onVisibilityChanged,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 900),
          opacity: _opacity,
          curve: Curves.easeOut,
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 768;
    final bodySize = isMobile ? 16.0 : 18.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? screenWidth * 0.05 : 80,
        vertical: isMobile ? screenHeight * 0.04 : 100,
      ),
      child: Stack(
        children: [
          // Animated background particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    _particles,
                    _particleController.value,
                    theme.colorScheme.secondary,
                  ),
                );
              },
            ),
          ),
          // Main content
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isMobile ? screenWidth * 0.9 : 1200),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Professional section title
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20 : 24, 
                      vertical: isMobile ? 8 : 12
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(isMobile ? 25 : 30),
                      border: Border.all(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      color: theme.colorScheme.surface.withValues(alpha: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          theme.colorScheme.secondary,
                          theme.colorScheme.primary,
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'About Me',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontSize: isMobile ? 24 : 32,
                          fontWeight: FontWeight.bold,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white
                              : theme.textTheme.displayMedium!.color,
                          shadows: theme.brightness == Brightness.dark
                              ? [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    offset: const Offset(0, 2),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 24 : 32),
                  
                  // Content layout
                  if (isMobile) 
                    _buildMobileContent(theme, bodySize, screenWidth, screenHeight)
                  else
                    _buildDesktopContent(theme, bodySize),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mobile layout content with professional design
  Widget _buildMobileContent(ThemeData theme, double bodySize, double screenWidth, double screenHeight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Professional profile image with enhanced styling
        Container(
          width: screenWidth * 0.4,
          height: screenWidth * 0.4,
          margin: EdgeInsets.only(bottom: screenHeight * 0.03),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.secondary.withValues(alpha: 0.3),
                theme.colorScheme.primary.withValues(alpha: 0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: ClipOval(
              child: ImageWidgets.profile(
                size: screenWidth * 0.38,
              ),
            ),
          ),
        ),
        
        // Professional intro text with enhanced typography
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Main description with professional styling
              Text(
                'As a versatile digital native and product enthusiast, I bring a creative spark to every project, whether it\'s designing intuitive user experiences, developing cutting-edge AI solutions, or streamlining business processes.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: GoogleFonts.inter().fontFamily,
                  fontSize: bodySize + 1,
                  height: 1.6,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.w500,
                  color: theme.brightness == Brightness.dark 
                      ? Colors.white.withValues(alpha: 0.95)
                      : (theme.textTheme.bodyLarge?.color ?? Colors.black).withValues(alpha: 0.9),
                ),
              ),
              
              SizedBox(height: screenHeight * 0.025),
              
              // Leadership highlight
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.015,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  'I excel at transforming exciting ideas into tangible realities through impactful leadership and clear communication.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: GoogleFonts.inter().fontFamily,
                    fontSize: bodySize,
                    height: 1.5,
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: theme.brightness == Brightness.dark 
                        ? Colors.white.withValues(alpha: 0.9)
                        : theme.colorScheme.secondary,
                  ),
                ),
              ),
              
              SizedBox(height: screenHeight * 0.025),
              
              // Personal interests
              Text(
                'Beyond the digital realm, you might find me capturing moments through my lens while exploring new destinations and cultures. I find joy in nurturing life in my garden and satisfaction in creating something with my own hands.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: GoogleFonts.inter().fontFamily,
                  fontSize: bodySize,
                  height: 1.6,
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.w400,
                  color: theme.brightness == Brightness.dark 
                      ? Colors.white.withValues(alpha: 0.85)
                      : (theme.textTheme.bodyLarge?.color ?? Colors.black).withValues(alpha: 0.8),
                ),
              ),
              
              SizedBox(height: screenHeight * 0.025),
              
              // Call to action with professional styling
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: screenHeight * 0.015,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                      theme.colorScheme.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Let\'s connect and collaboratively build something extraordinary!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                    fontSize: bodySize + 1,
                    height: 1.4,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w700,
                    color: theme.brightness == Brightness.dark 
                        ? Colors.white
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Desktop layout content with two columns
  Widget _buildDesktopContent(ThemeData theme, double bodySize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column - Profile image
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.only(right: 32.0, top: 8.0),
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.16),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: OptimizedImageWidget(
                  assetPath: 'assets/images/profile.jpg',
                  width: double.infinity,
                  height: 320,
                  fit: BoxFit.cover,
                  semanticLabel: 'Profile picture',
                  useResponsiveSize: true,
                ),
              ),
            ),
          ),
        ),
        // Right column - Text content
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'As a versatile digital native and product enthusiast, I bring a creative spark to every project, whether it\'s designing intuitive user experiences, developing cutting-edge AI solutions, or streamlining business processes. I excel at transforming exciting ideas into tangible realities through impactful leadership and clear communication.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontFamily: GoogleFonts.inter().fontFamily,
                    fontSize: bodySize,
                    height: 1.7,
                    letterSpacing: 0.3,
                    color: theme.brightness == Brightness.dark 
                        ? Colors.white 
                        : (theme.textTheme.bodyLarge?.color ?? Colors.black).withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Beyond the digital realm, you might find me capturing moments through my lens while exploring new destinations and cultures. I find joy in nurturing life in my garden and satisfaction in creating something with my own hands. Let\'s connect and collaboratively build something extraordinary!',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontFamily: GoogleFonts.inter().fontFamily,
                    fontSize: bodySize,
                    height: 1.7,
                    letterSpacing: 0.3,
                    color: theme.brightness == Brightness.dark 
                        ? Colors.white 
                        : (theme.textTheme.bodyLarge?.color ?? Colors.black).withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Particle and painter classes
class _Particle {
  double x, y, radius, speed, direction, drift;
  _Particle(this.x, this.y, this.radius, this.speed, this.direction, this.drift);
  factory _Particle.random() {
    final rand = Random();
    return _Particle(
      rand.nextDouble(),
      rand.nextDouble(),
      8 + rand.nextDouble() * 10,
      0.08 + rand.nextDouble() * 0.12,
      rand.nextDouble() * 2 * pi,
      rand.nextDouble() * 0.5 - 0.25,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  final Color color;
  _ParticlePainter(this.particles, this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha(30)
      ..style = PaintingStyle.fill;
    for (final p in particles) {
      final dx = p.x * size.width + cos(p.direction + t * 2 * pi) * p.drift * size.width * 0.2;
      final dy = (p.y * size.height + sin(p.direction + t * 2 * pi) * p.drift * size.height * 0.2 + t * p.speed * size.height) % size.height;
      canvas.drawCircle(Offset(dx, dy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 