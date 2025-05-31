import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Import flutter_animate
import '../utils/error_handler.dart';
import '../widgets/optimized_lottie_widget.dart';

/// Hero section of the portfolio website with animated background and elegant design.
/// 
/// This widget properly manages all AnimationControllers and Tickers to prevent memory leaks.
/// It includes graceful error handling for asset loading and network interruptions.
class HeroSection extends StatefulWidget {
  final ScrollController? scrollController;
  const HeroSection({super.key, this.scrollController});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> with TickerProviderStateMixin {
  // Animation controllers - all properly managed for lifecycle
  late AnimationController _introAnimationController;
  late Animation<double> _introAnimation;
  
  // Marquee animation controller
  AnimationController? _marqueeController;
  
  // Marquee measurement variables
  double _taglineTextWidth = 0;
  final GlobalKey _taglineTextKey = GlobalKey();
  final String _taglineContent = "Bringing Digital & AI Product Innovations to Life.";
  double _marqueeViewportWidth = 0; // To store the width of the marquee container

  @override
  void initState() {
    super.initState();
    
    // Initialize intro animation controller
    _introAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _introAnimation = CurvedAnimation(
      parent: _introAnimationController,
      curve: Curves.easeInOut,
    );
    _introAnimationController.forward();

    // Setup marquee animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupMarqueeAnimation();
    });
  }

  /// Sets up the marquee animation after the widget is built
  void _setupMarqueeAnimation() {
    if (!mounted) return;
    
    try {
      // Measure tagline text width
      final taglineContext = _taglineTextKey.currentContext;
      if (taglineContext != null) {
        final RenderBox? taglineRenderBox = taglineContext.findRenderObject() as RenderBox?;
        if (taglineRenderBox?.hasSize == true) {
          _taglineTextWidth = taglineRenderBox!.size.width;
        }
      }

      // Get marquee viewport width
      final RenderBox? columnRenderBox = context.findRenderObject() as RenderBox?;
      if (columnRenderBox?.hasSize == true) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobileScreen = screenWidth < 600;
        _marqueeViewportWidth = isMobileScreen ? screenWidth * 0.85 : screenWidth * 0.45;
      }
      
      // Initialize marquee controller if measurements are valid
      if (_taglineTextWidth > 0 && _marqueeViewportWidth > 0 && mounted) {
        setState(() {
          // Safely dispose existing controller if any
          try {
            _marqueeController?.stop();
            _marqueeController?.dispose();
          } catch (e) {
            debugPrint('Error disposing previous marquee controller: $e');
          }
          
          // Create new controller only if still mounted
          if (mounted) {
            _marqueeController = AnimationController(
              // Duration based on total scroll distance to maintain relatively consistent speed
              duration: Duration(seconds: ((_marqueeViewportWidth + _taglineTextWidth) / 50).clamp(6, 20).toInt()),
              vsync: this,
            );
            // Start animation only if still mounted
            if (mounted) {
              _marqueeController?.repeat();
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error setting up marquee animation: $e');
      // Gracefully handle any errors in marquee setup
    }
  }

  @override
  void dispose() {
    // Use the safe disposal utility from ErrorHandler
    ErrorHandler.safeDisposeControllers(
      [_introAnimationController, _marqueeController],
      names: ['IntroController', 'MarqueeController'],
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ErrorHandler.errorBoundary(
      errorContext: 'HeroSection',
      child: _buildHeroContent(context),
    );
  }

  Widget _buildHeroContent(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    
    // Enhanced professional responsive sizing
    final double headingSize = isMobile ? 36 : (isTablet ? 52 : 64);
    final double subheadingSize = isMobile ? 20 : (isTablet ? 26 : 32);
    final double taglineSize = isMobile ? 16 : (isTablet ? 18 : 22);

    // Update marquee viewport width if screen size changes
    final currentMarqueeViewportWidth = isMobile ? screenWidth * 0.85 : screenWidth * 0.45;
    if (_marqueeViewportWidth == 0 || _marqueeViewportWidth != currentMarqueeViewportWidth) {
      _marqueeViewportWidth = currentMarqueeViewportWidth;
    }

    TextStyle taglineStyle = GoogleFonts.playfairDisplay(
      fontSize: taglineSize,
      fontWeight: FontWeight.w600,
      color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.95),
      height: 1.6,
      letterSpacing: 0.8,
      fontStyle: FontStyle.italic,
    );

    // Enhanced Mobile Layout - Original styling with bigger animation
    if (isMobile) {
      return Container(
        height: screenHeight,
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: 600,
          maxHeight: screenHeight,
        ),
        child: Column(
          children: [
            // Enhanced top section with original premium gradient and content
            Expanded(
              flex: 55, // Slightly reduced to give more space to animation
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: 300,
                  maxHeight: screenHeight * 0.6,
                ),
                decoration: BoxDecoration(
                  gradient: theme.brightness == Brightness.dark
                      ? const LinearGradient(
                          colors: [
                            Colors.black, 
                            Color(0xFF1A1A2E),
                            Color(0xFF16213E),
                            Color(0xFF9A67EA)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.0, 0.3, 0.7, 1.0],
                        )
                      : LinearGradient(
                          colors: [
                            Colors.white,
                            theme.colorScheme.primary.withValues(alpha: 0.05),
                            theme.colorScheme.secondary.withValues(alpha: 0.08),
                            theme.colorScheme.primary.withValues(alpha: 0.12),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.3, 0.7, 1.0],
                        ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenHeight * 0.04,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Original greeting without extra containers
                        FadeTransition(
                          opacity: _introAnimation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, -0.3),
                              end: Offset.zero,
                            ).animate(_introAnimation),
                            child: Text(
                              'Hi, I\'m Chandranshu',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: headingSize,
                                fontWeight: FontWeight.bold,
                                color: theme.brightness == Brightness.dark 
                                    ? Colors.white 
                                    : theme.textTheme.displayLarge?.color,
                                letterSpacing: 1.5,
                                height: 1.2,
                                shadows: [
                                  Shadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                    offset: const Offset(0, 2),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.035),
                        
                        // Original professional tagline without extra containers
                        Text(
                          'Igniting Ideas, Architecting Experiences!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: subheadingSize,
                            fontWeight: FontWeight.w700,
                            color: theme.brightness == Brightness.dark 
                                ? Colors.white.withValues(alpha: 0.95)
                                : theme.colorScheme.secondary,
                            letterSpacing: 1.2,
                            height: 1.3,
                            shadows: [
                              Shadow(
                                color: theme.brightness == Brightness.dark 
                                    ? Colors.black.withValues(alpha: 0.3) 
                                    : theme.colorScheme.primary.withValues(alpha: 0.15),
                                offset: const Offset(0, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ).animate(effects: [
                          FadeEffect(delay: 300.ms, duration: 700.ms),
                          SlideEffect(begin: const Offset(0, 0.2), delay: 300.ms, duration: 700.ms),
                          ScaleEffect(begin: const Offset(0.8, 0.8), delay: 300.ms, duration: 700.ms)
                        ]),
                        
                        SizedBox(height: screenHeight * 0.03),
                        
                        // Original premium accent line
                        Container(
                          height: 4,
                          width: screenWidth * 0.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.secondary.withValues(alpha: 0.3),
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary.withValues(alpha: 0.3),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                blurRadius: 12,
                                spreadRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ).animate(effects: [
                          FadeEffect(delay: 500.ms, duration: 800.ms),
                          ScaleEffect(begin: const Offset(0.0, 1.0), end: const Offset(1.0, 1.0), delay: 500.ms, duration: 1000.ms),
                          ShimmerEffect(delay: 1200.ms, duration: 2000.ms)
                        ]),
                        
                        SizedBox(height: screenHeight * 0.035),
                        
                        // Original marquee tagline with better styling
                        Container(
                          width: screenWidth * 0.85,
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                          child: _marqueeController != null && _taglineTextWidth > 0 && _marqueeViewportWidth > 0 && _taglineTextWidth > _marqueeViewportWidth
                              ? Container(
                                  height: taglineSize * 2.8,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: theme.colorScheme.surface.withValues(alpha: 0.1),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: AnimatedBuilder(
                                      animation: _marqueeController!,
                                      builder: (context, child) {
                                        double currentX = _marqueeViewportWidth -
                                            (_marqueeController!.value * (_marqueeViewportWidth + _taglineTextWidth));
                                        return Transform.translate(
                                          offset: Offset(currentX, 0),
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(_taglineContent, style: taglineStyle),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: theme.colorScheme.surface.withValues(alpha: 0.1),
                                    border: Border.all(
                                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    _taglineContent,
                                    style: taglineStyle,
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                        ).animate().fadeIn(delay: 700.ms, duration: 800.ms),
                        
                        // Hidden text for measurement
                        Opacity(
                          opacity: 0.0,
                          child: Text(_taglineContent, key: _taglineTextKey, style: taglineStyle),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Enhanced Bottom section with BIGGER Lottie animation
            Expanded(
              flex: 45, // Increased from 40 to give more space
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: theme.brightness == Brightness.dark
                      ? LinearGradient(
                          colors: [
                            const Color(0xFF9A67EA).withValues(alpha: 0.4),
                            const Color(0xFF16213E).withValues(alpha: 0.6),
                            Colors.black.withValues(alpha: 0.9),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : LinearGradient(
                          colors: [
                            theme.colorScheme.secondary.withValues(alpha: 0.08),
                            theme.colorScheme.primary.withValues(alpha: 0.05),
                            theme.colorScheme.surface.withValues(alpha: 0.98),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                ),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: LottieWidgets.hero(
                      assetPath: 'assets/lottie/hero_animation.json',
                      size: screenWidth * 0.8, // Bigger mobile animation as requested!
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ENHANCED Desktop Layout - Original styling
    return Container(
      height: screenHeight,
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 700,
        maxHeight: screenHeight,
      ),
      child: Stack(
        children: [
          // Original premium animated background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: theme.brightness == Brightness.dark
                    ? const LinearGradient(
                        colors: [
                          Colors.black,
                          Color(0xFF1A1A2E),
                          Color(0xFF16213E),
                          Color(0xFF9A67EA)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.0, 0.3, 0.7, 1.0],
                      )
                    : LinearGradient(
                        colors: [
                          Colors.white,
                          theme.colorScheme.primary.withValues(alpha: 0.03),
                          theme.colorScheme.secondary.withValues(alpha: 0.05),
                          theme.colorScheme.primary.withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
              ),
            ),
          ),
          
          // Enhanced Lottie animation for desktop - Better positioned
          Positioned(
            right: screenWidth * 0.05, // Better margin
            top: 0,
            bottom: 0,
            width: screenWidth * 0.5, // Evenly spaced
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      blurRadius: 40,
                      spreadRadius: 10,
                      offset: const Offset(-5, 10),
                    ),
                  ],
                ),
                child: LottieWidgets.hero(
                  assetPath: 'assets/lottie/hero_animation.json',
                  size: screenWidth * 0.4, // Increased from 0.35 to 0.4
                ),
              ),
            ),
          ),
          
          // CENTERED Content for desktop - Original styling
          Positioned(
            left: screenWidth * 0.05,
            top: 0,
            bottom: 0,
            width: screenWidth * 0.45, // Even split with animation
            child: Center( // This centers the entire content block
              child: Column(
                mainAxisSize: MainAxisSize.min, // Important for centering
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Original desktop greeting
                  FadeTransition(
                    opacity: _introAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-0.2, 0),
                        end: Offset.zero,
                      ).animate(_introAnimation),
                      child: Text(
                        'Hi, I\'m Chandranshu',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: headingSize,
                          fontWeight: FontWeight.bold,
                          color: theme.brightness == Brightness.dark 
                              ? Colors.white 
                              : theme.textTheme.displayLarge?.color,
                          letterSpacing: 2.0,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              offset: const Offset(0, 3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Original professional tagline
                  Text(
                    'Igniting Ideas, Architecting Experiences!',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: subheadingSize,
                      fontWeight: FontWeight.w700,
                      color: theme.brightness == Brightness.dark 
                          ? Colors.white.withValues(alpha: 0.95)
                          : theme.colorScheme.secondary,
                      letterSpacing: 1.5,
                      height: 1.3,
                      shadows: [
                        Shadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          offset: const Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ).animate(effects: [
                    FadeEffect(delay: 300.ms, duration: 800.ms),
                    SlideEffect(begin: const Offset(-0.1, 0), delay: 300.ms, duration: 800.ms),
                    ScaleEffect(begin: const Offset(0.9, 0.9), delay: 300.ms, duration: 800.ms)
                  ]),
                  
                  const SizedBox(height: 28),
                  
                  // Original premium accent line
                  Container(
                    height: 5,
                    width: screenWidth * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.secondary.withValues(alpha: 0.3),
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary.withValues(alpha: 0.3),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.6),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ).animate(effects: [
                    FadeEffect(delay: 600.ms, duration: 1000.ms),
                    ScaleEffect(begin: const Offset(0.0, 1.0), end: const Offset(1.0, 1.0), delay: 600.ms, duration: 1200.ms),
                    ShimmerEffect(delay: 1500.ms, duration: 2500.ms)
                  ]),
                  
                  const SizedBox(height: 32),
                  
                  // Original desktop tagline with premium container
                  Container(
                    width: screenWidth * 0.4,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: theme.colorScheme.surface.withValues(alpha: 0.1),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                          blurRadius: 15,
                          spreadRadius: 1,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      _taglineContent,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: taglineSize,
                        fontWeight: FontWeight.w600,
                        color: theme.brightness == Brightness.dark 
                            ? Colors.white.withValues(alpha: 0.9)
                            : theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.95),
                        height: 1.6,
                        letterSpacing: 0.8,
                        fontStyle: FontStyle.italic,
                        shadows: [
                          Shadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.visible,
                    ),
                  ).animate(effects: [
                    FadeEffect(delay: 800.ms, duration: 1000.ms),
                    SlideEffect(begin: const Offset(-0.1, 0), delay: 800.ms, duration: 1000.ms),
                    ScaleEffect(begin: const Offset(0.95, 0.95), delay: 800.ms, duration: 1000.ms)
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 