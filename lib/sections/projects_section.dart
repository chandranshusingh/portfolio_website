import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui'; // For ImageFilter (glass effect)
import '../utils/error_handler.dart';

/// Projects section of the portfolio website with slide-in, fade-in, parallax, and interactive cards.
///
/// Performance: Uses RepaintBoundary for animated/complex widgets to reduce unnecessary repaints.
/// Accessibility: Adds keyboard navigation, semantic labels, tooltips, skip-to-content link, and WCAG-compliant color contrast.
class ProjectsSection extends StatefulWidget {
  final ScrollController? scrollController;
  const ProjectsSection({super.key, this.scrollController});

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class Project {
  final String title;
  final String description;
  final List<String> tech;
  final String url;

  Project({
    required this.title,
    required this.description,
    required this.tech,
    required this.url,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      title: json['title'] as String,
      description: json['description'] as String,
      tech: List<String>.from(json['tech'] as List),
      url: json['url'] as String,
    );
  }
}

class _ProjectsSectionState extends State<ProjectsSection> with TickerProviderStateMixin {
  double _opacity = 0.0;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isHovered = false;
  late AnimationController _particleController;
  final int _particleCount = 6;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _particles = List.generate(_particleCount, (i) => _Particle.random());
  }

  @override
  void dispose() {
    ErrorHandler.safeDisposeControllers(
      [_controller, _particleController],
      names: ['ProjectsMainController', 'ProjectsParticleController'],
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

  Future<List<Project>> _loadProjects() async {
    try {
      // Try to load the projects data
      final String jsonString = await DefaultAssetBundle.of(context).loadString('assets/data/projects.json');
      if (jsonString.trim().isEmpty) {
        throw Exception('Projects data is empty.');
      }
      
      // Parse the JSON data
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      if (jsonList.isEmpty) {
        throw Exception('No projects found.');
      }
      
      return jsonList.map((json) => Project.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      // Log the error
      debugPrint('Error loading projects: $e');
      
      // For web, provide a fallback projects data
      if (kIsWeb) {
        debugPrint('Using fallback projects data for web');
        return [
          Project.fromJson({
            "title": "Portfolio Website",
            "description": "A posh, responsive portfolio built with Flutter Web.",
            "tech": ["Flutter", "Dart", "Web"],
            "url": "https://yourportfolio.com"
          })
        ];
      }
      
      // For non-web platforms, rethrow the exception
      throw Exception('Failed to load projects. Please check your data file.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final double headingSize = isMobile ? 28 : 36;
    final EdgeInsets sectionPadding = MediaQuery.of(context).size.width < 800
        ? const EdgeInsets.symmetric(vertical: 56, horizontal: 16)
        : const EdgeInsets.symmetric(vertical: 80, horizontal: 40);

    // Parallax offset based on scroll position
    double parallax = 0;
    if (widget.scrollController != null && widget.scrollController!.hasClients) {
      parallax = (widget.scrollController!.offset * 0.07).clamp(-30.0, 30.0);
    }

    return VisibilityDetector(
      key: const Key('projects-section'),
      onVisibilityChanged: _onVisibilityChanged,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 900),
        opacity: _opacity,
        curve: Curves.easeOut,
        child: SlideTransition(
          position: _slideAnimation,
          child: Stack(
            children: [
              Positioned.fill(
                top: parallax,
                child: IgnorePointer(
                  child: Stack(
                    children: [
                      Positioned(
                        left: isMobile ? 10 : 20,
                        bottom: isMobile ? 15 : 30,
                        child: AnimatedBuilder(
                          animation: _particleController,
                          builder: (context, child) {
                            final double t = _particleController.value;
                            return Transform.translate(
                              offset: Offset(cos(t * 2 * pi + pi / 2) * 9, sin(t * 2 * pi + pi / 2) * 9),
                              child: Opacity(
                                opacity: 0.09,
                                child: SvgPicture.string(_svgBlob,
                                    width: isMobile ? 45 : 85,
                                    height: isMobile ? 45 : 85,
                                    colorFilter: ColorFilter.mode(
                                      theme.colorScheme.secondary.withAlpha((0.65 * 255).round()),
                                      BlendMode.srcIn,
                                    )),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _particleController,
                          builder: (context, child) {
                            return RepaintBoundary(
                              child: CustomPaint(
                                painter: _ParticlePainter(
                                  _particles,
                                  _particleController.value,
                                  theme.colorScheme.secondary.withAlpha((0.55 * 255).round()),
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
                padding: sectionPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      label: 'Skip to Projects content',
                      child: FocusableActionDetector(
                        onShowHoverHighlight: (v) {},
                        child: Builder(
                          builder: (context) => GestureDetector(
                            onTap: () {
                              final focus = FocusScope.of(context);
                              focus.nextFocus();
                            },
                            child: SizedBox(
                              width: 1,
                              height: 1,
                              child: const Text('Skip to Projects content', style: TextStyle(fontSize: 0)),
                            ),
                          ),
                        ),
                      ),
                    ),
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
                                      offset: Offset(0, 2),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: const Text('Projects'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FutureBuilder<List<Project>>(
                      future: _loadProjects(),
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
                                  Icon(Icons.now_widgets_outlined, color: theme.colorScheme.error, size: 52),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Failed to load projects.',
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
                        final projects = snapshot.data ?? [];
                        if (projects.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.layers_clear_outlined, color: theme.colorScheme.secondary, size: 52),
                                  const SizedBox(height: 20),
                                  Text(
                                    'No projects to display yet.',
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
                        return RepaintBoundary(
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isMobile ? 1 : (width < 900 ? 2 : 3),
                              mainAxisSpacing: isMobile ? 28 : 28,
                              crossAxisSpacing: isMobile ? 24 : 28,
                              childAspectRatio: isMobile ? 0.95 : (width < 900 ? 1.1 : 1.2),
                            ),
                            itemCount: projects.length,
                            itemBuilder: (context, index) {
                              final project = projects[index];
                              return ProjectCard(
                                title: project.title,
                                description: project.description,
                                tech: project.tech,
                                url: project.url,
                              ).animate()
                               .fadeIn(delay: (150 * index).ms, duration: 400.ms)
                               .slideY(begin: 0.15, delay: (150 * index).ms, duration: 350.ms, curve: Curves.easeOutCubic);
                            },
                          ),
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

class _Particle {
  double x, y, radius, speed, direction, drift;
  _Particle(this.x, this.y, this.radius, this.speed, this.direction, this.drift);
  factory _Particle.random() {
    final rand = Random();
    return _Particle(
      rand.nextDouble(),
      rand.nextDouble(),
      7 + rand.nextDouble() * 9,
      0.07 + rand.nextDouble() * 0.11,
      rand.nextDouble() * 2 * pi,
      rand.nextDouble() * 0.45 - 0.22,
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
      final dx = p.x * size.width + cos(p.direction + t * 2 * pi) * p.drift * size.width * 0.18;
      final dy = (p.y * size.height + sin(p.direction + t * 2 * pi) * p.drift * size.height * 0.18 + t * p.speed * size.height) % size.height;
      canvas.drawCircle(Offset(dx, dy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

const String _svgBlob = '''<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg"><path fill="currentColor" d="M44.8,-67.6C56.2,-60.2,62.7,-44.2,68.2,-28.7C73.7,-13.2,78.2,1.8,75.2,15.2C72.2,28.6,61.7,40.4,49.2,48.7C36.7,57,22.2,61.8,7.2,66.2C-7.8,70.6,-23.5,74.6,-36.2,69.2C-48.9,63.8,-58.6,49,-65.2,34.1C-71.8,19.2,-75.3,4.1,-74.2,-11.2C-73.1,-26.5,-67.4,-41.9,-56.6,-49.2C-45.8,-56.5,-29.9,-55.7,-14.7,-62.2C0.5,-68.7,15.9,-82.5,29.7,-81.2C43.5,-79.9,56.2,-73.1,44.8,-67.6Z" transform="translate(100 100)"/></svg>''';

/// Displays a project with interactive elements and refined styling.
class ProjectCard extends StatefulWidget {
  final String title;
  final String description;
  final List<String> tech;
  final String url;

  const ProjectCard({
    super.key,
    required this.title,
    required this.description,
    required this.tech,
    required this.url,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _isHovered = false;

  Future<void> _launchProjectUrl() async {
    final Uri uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Optionally, show a snackbar or dialog if the URL can't be launched
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch ${widget.url}')),
        );
      }
      debugPrint('Could not launch ${widget.url}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _launchProjectUrl,
        child: AnimatedScale(
          scale: _isHovered && !isMobile ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Card(
            elevation: _isHovered && !isMobile 
                ? (isDarkMode ? 8 : 10) 
                : (isDarkMode ? 3 : 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: isDarkMode
                  ? BorderSide(color: theme.colorScheme.onSurface.withAlpha(((_isHovered && !isMobile ? 0.25 : 0.12) * 255).round()), width: 1)
                  : BorderSide.none,
            ),
            color: isDarkMode ? theme.colorScheme.surface.withAlpha(180) : theme.cardColor,
            child: isDarkMode
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        color: theme.colorScheme.surface.withAlpha((0.55 * 255).round()),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: isMobile ? 18 : 20,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.secondary, 
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: Text(
                                  widget.description,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: isMobile ? 13 : 14,
                                    height: 1.5,
                                    color: theme.textTheme.bodyMedium?.color?.withAlpha(((isDarkMode ? 0.85 : 0.9) * 255).round()),
                                  ),
                                  maxLines: isMobile ? 3 : 4, // More lines for description
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: widget.tech.map((t) => Chip(
                                  label: Text(t),
                                  labelStyle: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSecondary.withAlpha((0.9 * 255).round()),
                                  ),
                                  backgroundColor: theme.colorScheme.secondary.withAlpha(((isDarkMode ? 0.3 : 0.25) * 255).round()),
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: isDarkMode ? Colors.white.withAlpha((0.22 * 255).round()) : theme.colorScheme.secondary.withAlpha((0.22 * 255).round()),
                                      width: 1.2,
                                    ),
                                  ),
                                )).toList(),
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: TextButton.icon(
                                  onPressed: _launchProjectUrl,
                                  icon: Icon(Icons.open_in_new_rounded, size: 18, color: theme.colorScheme.primary),
                                  label: Text(
                                    'View Project',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.secondary, 
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Text(
                            widget.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: isMobile ? 13 : 14,
                              height: 1.5,
                              color: theme.textTheme.bodyMedium?.color?.withAlpha(((isDarkMode ? 0.85 : 0.9) * 255).round()),
                            ),
                            maxLines: isMobile ? 3 : 4, // More lines for description
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: widget.tech.map((t) => Chip(
                            label: Text(t),
                            labelStyle: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSecondary.withAlpha((0.9 * 255).round()),
                            ),
                            backgroundColor: theme.colorScheme.secondary.withAlpha(((isDarkMode ? 0.3 : 0.25) * 255).round()),
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isDarkMode ? Colors.white.withAlpha((0.22 * 255).round()) : theme.colorScheme.secondary.withAlpha((0.22 * 255).round()),
                                width: 1.2,
                              ),
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton.icon(
                            onPressed: _launchProjectUrl,
                            icon: Icon(Icons.open_in_new_rounded, size: 18, color: theme.colorScheme.primary),
                            label: Text(
                              'View Project',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
} 