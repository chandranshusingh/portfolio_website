import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/error_handler.dart';

/// Experience section of the portfolio website with slide-in and fade-in animation and posh style.
class ExperienceSection extends StatefulWidget {
  final ScrollController? scrollController;
  const ExperienceSection({super.key, this.scrollController});

  @override
  State<ExperienceSection> createState() => _ExperienceSectionState();
}

class _ExperienceSectionState extends State<ExperienceSection> with TickerProviderStateMixin {
  double _opacity = 0.0;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isHovered = false;
  late AnimationController _particleController;
  final int _particleCount = 7;
  late List<_Particle> _particles;

  // Load experience data from JSON with enhanced error handling
  Future<List<Map<String, dynamic>>> _loadExperience() async {
    return await ErrorHandler.safeAsyncOperation<List<Map<String, dynamic>>>(
      operation: () async {
        // Try to load the experience data
        final String jsonString = await rootBundle.loadString('assets/data/experience.json');
        if (jsonString.trim().isEmpty) {
          throw Exception('Experience data is empty.');
        }
        
        // Parse the JSON data
        final List<dynamic> jsonData = json.decode(jsonString);
        if (jsonData.isEmpty) {
          throw Exception('No experience found.');
        }
        
        return jsonData.cast<Map<String, dynamic>>();
      },
      operationName: 'LoadExperienceData',
      fallbackValue: kIsWeb ? [
        {
          "role": "Flutter Developer",
          "company": "Tech Solutions Inc.",
          "duration": "2020 - Present",
          "description": "Developed cross-platform mobile and web apps using Flutter. Led a team of 4 developers."
        }
      ] : null,
    ) ?? (throw Exception('Failed to load experience. Please check your data file.'));
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    // Particle animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 13),
    )..repeat();
    _particles = List.generate(_particleCount, (i) => _Particle.random());
  }

  @override
  void dispose() {
    // Use ErrorHandler.safeDisposeControllers for robust disposal
    ErrorHandler.safeDisposeControllers(
      [_controller, _particleController],
      names: ['ExperienceMainController', 'ExperienceParticleController'],
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
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;
    final double headingSize = isMobile ? 22 : 36;

    // Parallax for background elements
    double parallax = 0;
    if (widget.scrollController != null && widget.scrollController!.hasClients) {
      parallax = (widget.scrollController!.offset * 0.07).clamp(-30.0, 30.0);
    }

    return VisibilityDetector(
      key: const Key('experience-section'),
      onVisibilityChanged: _onVisibilityChanged,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 900),
        opacity: _opacity,
        curve: Curves.easeOut,
        child: SlideTransition(
          position: _slideAnimation,
          child: Stack(
            children: [
              // Parallax background elements (subtler)
              Positioned.fill(
                top: parallax,
                child: IgnorePointer(
                  child: Stack(
                    children: [
                      // Animated SVG
                      Positioned(
                        right: 24,
                        bottom: 32,
                        child: AnimatedBuilder(
                          animation: _particleController,
                          builder: (context, child) {
                            final double t = _particleController.value;
                            return Transform.translate(
                              offset: Offset(cos(t * 2 * pi) * 8, sin(t * 2 * pi) * 8),
                              child: Opacity(
                                opacity: 0.08,
                                child: SvgPicture.string(_svgBlob,
                                    width: isMobile ? 50 : 90,
                                    height: isMobile ? 50 : 90,
                                    colorFilter: ColorFilter.mode(
                                      theme.colorScheme.secondary.withAlpha((0.7 * 255).round()),
                                      BlendMode.srcIn,
                                    )),
                              ),
                            );
                          },
                        ),
                      ),
                      // Animated particles
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _particleController,
                          builder: (context, child) {
                            return RepaintBoundary(
                              child: CustomPaint(
                                painter: _ParticlePainter(
                                  _particles,
                                  _particleController.value,
                                  theme.colorScheme.secondary.withAlpha((0.6 * 255).round()),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16.0 : 32.0,
                  vertical: isMobile ? 12.0 : 24.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MouseRegion(
                      onEnter: (_) => setState(() => _isHovered = true),
                      onExit: (_) => setState(() => _isHovered = false),
                      child: AnimatedScale(
                        scale: _isHovered && !isMobile ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 250),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: theme.textTheme.displayMedium!.copyWith(
                            fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.3,
                            fontSize: headingSize,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : (_isHovered && !isMobile
                                    ? theme.colorScheme.secondary
                                    : theme.textTheme.displayMedium!.color),
                            shadows: theme.brightness == Brightness.dark
                                ? [
                                    Shadow(
                                      color: Colors.black.withAlpha((0.45 * 255).round()),
                                      offset: const Offset(0, 2),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: const Text('Experience'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _loadExperience(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 52),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Failed to load experience.',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: theme.colorScheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Please check your data connection or the data file and try again later.',
                                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        final experience = snapshot.data!;
                        if (experience.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inbox_outlined, color: theme.colorScheme.secondary, size: 48),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No experience to display at the moment.',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: theme.colorScheme.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                     textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        // Dynamic height layout with professional grid appearance
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            if (isMobile || constraints.maxWidth < 900) {
                              // Mobile: Single column with optimized spacing
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: experience.asMap().entries.map((entry) {
                                  int idx = entry.key;
                                  Map<String, dynamic> exp = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: _ExperienceCard(exp: exp)
                                      .animate()
                                      .fadeIn(delay: (150 * idx).ms, duration: 500.ms)
                                      .slideY(begin: 0.2, delay: (150 * idx).ms, duration: 400.ms, curve: Curves.easeOutCubic),
                                  );
                                }).toList(),
                              );
                            } else {
                              // Desktop: Dynamic masonry-style layout
                              final int columns = constraints.maxWidth > 1200 ? 3 : 2;
                              return _DynamicExperienceGrid(
                                experienceList: experience,
                                columns: columns,
                                spacing: 20.0,
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom grid widget that allows dynamic card heights in a professional layout
class _DynamicExperienceGrid extends StatelessWidget {
  final List<Map<String, dynamic>> experienceList;
  final int columns;
  final double spacing;

  const _DynamicExperienceGrid({
    required this.experienceList,
    required this.columns,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    // Distribute cards across columns for balanced layout
    List<List<Map<String, dynamic>>> columnItems = List.generate(columns, (_) => []);
    
    for (int i = 0; i < experienceList.length; i++) {
      columnItems[i % columns].add(experienceList[i]);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(columns, (columnIndex) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: columnIndex < columns - 1 ? spacing : 0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: columnItems[columnIndex].asMap().entries.map((entry) {
                  final globalIndex = columnIndex + (entry.key * columns);
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: entry.key < columnItems[columnIndex].length - 1 ? spacing : 0,
                    ),
                    child: _ExperienceCard(exp: entry.value)
                      .animate()
                      .fadeIn(delay: (150 * globalIndex).ms, duration: 500.ms)
                      .slideY(begin: 0.2, delay: (150 * globalIndex).ms, duration: 400.ms, curve: Curves.easeOutCubic),
                  );
                }).toList(),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Card widget for displaying experience data with enhanced UI and hover effect.
class _ExperienceCard extends StatefulWidget {
  final Map<String, dynamic> exp;
  const _ExperienceCard({required this.exp});

  @override
  State<_ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<_ExperienceCard> {
  bool _isHovered = false;
  bool _showDetails = false; // Single toggle for both description and skills

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered && !isMobile ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Card(
          margin: EdgeInsets.symmetric(vertical: isMobile ? 4.0 : 6.0),
          elevation: _isHovered && !isMobile 
              ? (isDarkMode ? 8 : 10) 
              : (isDarkMode ? 4 : 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(
              color: _isHovered && !isMobile
                ? theme.colorScheme.secondary.withAlpha((0.3 * 255).round())
                : theme.colorScheme.onSurface.withAlpha((0.1 * 255).round()),
              width: _isHovered && !isMobile ? 1.5 : 1.0,
            ),
          ),
          color: _isHovered && !isMobile
              ? (isDarkMode 
                  ? theme.colorScheme.surface.withAlpha(250)
                  : theme.cardColor.withAlpha(255))
              : (isDarkMode 
                  ? theme.colorScheme.surface.withAlpha(230) 
                  : theme.cardColor),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Role with colored accent
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.secondary.withAlpha((0.7 * 255).round()),
                            theme.colorScheme.primary.withAlpha((0.9 * 255).round()),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.exp['role'] ?? 'N/A',
                        style: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.w700,
                          fontSize: isMobile ? 15 : 18,
                          color: theme.brightness == Brightness.dark ? Colors.white : theme.colorScheme.secondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 3 : 6),
                Text(
                  widget.exp['company'] ?? 'N/A',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 13 : 15,
                    color: theme.brightness == Brightness.dark ? Colors.white : theme.textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                // Duration with subtle container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.exp['duration'] ?? 'N/A',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: theme.brightness == Brightness.dark ? Colors.white70 : theme.colorScheme.primary.withAlpha((0.9 * 255).round()),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Divider(
                  color: theme.colorScheme.onSurface.withAlpha(30),
                  height: 12,
                  thickness: 1,
                ),
                const SizedBox(height: 4),
                if (isMobile) ...[
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: _showDetails ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    firstChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.exp['description'] ?? 'No description available.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            height: 1.6,
                            color: theme.brightness == Brightness.dark ? Colors.white : theme.textTheme.bodyMedium?.color?.withAlpha((0.9 * 255).round()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (widget.exp['skills'] != null && widget.exp['skills'] is List)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (widget.exp['skills'] as List).map((skill) => Chip(
                              label: Text(
                                skill.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface.withAlpha((0.8 * 255).round()),
                                ),
                              ),
                              backgroundColor: theme.colorScheme.surface.withAlpha(120),
                              side: BorderSide(
                                color: theme.colorScheme.onSurface.withAlpha(30),
                                width: 1,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )).toList(),
                          ),
                      ],
                    ),
                    secondChild: const SizedBox.shrink(),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: Icon(_showDetails ? Icons.expand_less : Icons.expand_more),
                      label: Text(_showDetails ? 'Hide Details' : 'Show Details'),
                      onPressed: () => setState(() => _showDetails = !_showDetails),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.secondary,
                        textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    widget.exp['description'] ?? 'No description available.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      height: 1.6,
                      color: theme.brightness == Brightness.dark ? Colors.white : theme.textTheme.bodyMedium?.color?.withAlpha((0.9 * 255).round()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.exp['skills'] != null && widget.exp['skills'] is List)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (widget.exp['skills'] as List).map((skill) => Chip(
                        label: Text(
                          skill.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface.withAlpha((0.8 * 255).round()),
                          ),
                        ),
                        backgroundColor: theme.colorScheme.surface.withAlpha(120),
                        side: BorderSide(
                          color: theme.colorScheme.onSurface.withAlpha(30),
                          width: 1,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )).toList(),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Particle and painter classes (reuse from hero_section.dart)
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
      ..color = color.withAlpha(35)
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

const String _svgBlob = '''<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg"><path fill="currentColor" d="M44.8,-67.6C56.2,-60.2,62.7,-44.2,68.2,-28.7C73.7,-13.2,78.2,1.8,75.2,15.2C72.2,28.6,61.7,40.4,49.2,48.7C36.7,57,22.2,61.8,7.2,66.2C-7.8,70.6,-23.5,74.6,-36.2,69.2C-48.9,63.8,-58.6,49,-65.2,34.1C-71.8,19.2,-75.3,4.1,-74.2,-11.2C-73.1,-26.5,-67.4,-41.9,-56.6,-49.2C-45.8,-56.5,-29.9,-55.7,-14.7,-62.2C0.5,-68.7,15.9,-82.5,29.7,-81.2C43.5,-79.9,56.2,-73.1,44.8,-67.6Z" transform="translate(100 100)"/></svg>'''; 