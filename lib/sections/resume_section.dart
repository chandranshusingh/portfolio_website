import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/error_handler.dart';

/// Resume section of the portfolio website with slide-in and fade-in animation and posh style.
/// Features a downloadable PDF resume with a preview modal.
class ResumeSection extends StatefulWidget {
  final ScrollController? scrollController;
  const ResumeSection({super.key, this.scrollController});

  @override
  State<ResumeSection> createState() => _ResumeSectionState();
}

class _ResumeSectionState extends State<ResumeSection> with TickerProviderStateMixin {
  double _opacity = 0.0;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isTitleHovered = false;
  bool _isCardHovered = false;
  late AnimationController _particleController;
  final int _particleCount = 6;
  late List<_Particle> _particles;

  final String _resumeAssetPath = 'assets/resume.pdf';

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

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 17),
    )..repeat();
    _particles = List.generate(_particleCount, (i) => _Particle.random());
  }

  @override
  void dispose() {
    ErrorHandler.safeDisposeControllers(
      [_controller, _particleController],
      names: ['ResumeMainController', 'ResumeParticleController'],
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

  Future<void> _downloadResume() async {
    try {
      if (kIsWeb) {
        // For Flutter web, assets aren't directly accessible for download
        // Provide user guidance to use preview and browser download functionality
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Resume preview opened. Use browser menu to download.'),
              action: SnackBarAction(
                label: 'Preview',
                onPressed: _showResumePreview,
              ),
              duration: const Duration(seconds: 4),
            ),
          );
          _showResumePreview();
        }
      } else {
        // For mobile platforms: Use url_launcher with asset path
        final Uri resumeUri = Uri.parse('https://your-resume-url.com/resume.pdf'); // Replace with actual URL
        
        if (await canLaunchUrl(resumeUri)) {
          await launchUrl(
            resumeUri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          debugPrint('Could not launch resume URL for download.');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Could not open resume for download.'),
                action: SnackBarAction(
                  label: 'Preview',
                  onPressed: _showResumePreview,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error downloading resume: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error downloading resume. Opening preview instead.'),
            action: SnackBarAction(
              label: 'Preview',
              onPressed: _showResumePreview,
            ),
          ),
        );
        _showResumePreview();
      }
    }
  }

  void _showResumePreview() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
              AppBar(
                title: Text('Resume Preview', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
                backgroundColor: theme.colorScheme.primary,
                elevation: 1,
                iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.download_outlined),
                    onPressed: () {
                       _downloadResume();
                    },
                    tooltip: 'Download Resume',
                    color: theme.colorScheme.onPrimary,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_fullscreen_outlined),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Close Preview',
                    color: theme.colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              Expanded(
                child: RepaintBoundary(
                  child: SfPdfViewer.asset(
                    _resumeAssetPath,
                    canShowScrollHead: true,
                    canShowScrollStatus: true,
                    pageLayoutMode: PdfPageLayoutMode.continuous,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final bool isDarkMode = theme.brightness == Brightness.dark;

    final double headingSize = isMobile ? 22 : 36;
    final EdgeInsets sectionPadding = MediaQuery.of(context).size.width < 800
        ? const EdgeInsets.symmetric(vertical: 32, horizontal: 10)
        : const EdgeInsets.symmetric(vertical: 80, horizontal: 40);

    double parallax = 0;
    if (widget.scrollController != null && widget.scrollController!.hasClients) {
      parallax = (widget.scrollController!.offset * 0.06).clamp(-22.0, 22.0); 
    }

    // Define button style for better dark mode visibility
    final ButtonStyle downloadButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: isDarkMode ? theme.colorScheme.secondary : theme.colorScheme.primary,
      foregroundColor: isDarkMode ? theme.colorScheme.onSecondary : theme.colorScheme.onPrimary,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 18, // Adjusted padding slightly
        vertical: isMobile ? 8 : 14,   // Adjusted padding slightly
      ),
      textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: isMobile ? 11.5 : 14.5), // Slightly increased font weight & size
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Slightly larger border radius
      elevation: isDarkMode ? 3 : 2, // Adjusted elevation for dark mode
    );

    return VisibilityDetector(
      key: const Key('resume-section'),
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
                        left: isMobile ? 5 : 15, 
                        bottom: isMobile ? 10 : 20,
                        child: AnimatedBuilder(
                          animation: _particleController,
                          builder: (context, child) {
                            final double t = _particleController.value;
                            return Transform.scale(
                              scale: 1 + sin(t * 2 * pi) * 0.05, 
                              child: Opacity(
                                opacity: 0.07, 
                                child: SvgPicture.string(_svgBlob,
                                    width: isMobile ? 50 : 80,
                                    height: isMobile ? 50 : 80,
                                    colorFilter: ColorFilter.mode(
                                      theme.colorScheme.secondary.withAlpha((0.6 * 255).round()),
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
                                  theme.colorScheme.secondary.withAlpha((0.5 * 255).round()),
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
                    MouseRegion(
                      onEnter: (_) => setState(() => _isTitleHovered = true),
                      onExit: (_) => setState(() => _isTitleHovered = false),
                      child: AnimatedScale(
                        scale: _isTitleHovered && !isMobile ? 1.05 : 1.0,
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
                                : (_isTitleHovered && !isMobile
                                    ? theme.colorScheme.secondary
                                    : theme.textTheme.displayMedium!.color),
                            shadows: theme.brightness == Brightness.dark
                                ? [
                                    Shadow(
                                      color: Colors.black.withAlpha(45),
                                      offset: Offset(0, 2),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: const Text('Resume'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    MouseRegion(
                       onEnter: (_) => setState(() => _isCardHovered = true),
                       onExit: (_) => setState(() => _isCardHovered = false),
                       child: AnimatedScale(
                        scale: _isCardHovered && !isMobile ? 1.02 : 1.0,
                        duration: const Duration(milliseconds: 200),
                         child: Card(
                           elevation: _isCardHovered && !isMobile 
                               ? (isDarkMode ? 7 : 8) 
                               : (isDarkMode ? 3 : 4),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                           color: isDarkMode ? theme.colorScheme.surface.withAlpha(210) : theme.cardColor.withAlpha(240),
                           margin: EdgeInsets.symmetric(
                             vertical: isMobile ? 12 : 10,
                             horizontal: isMobile ? 0 : 0,
                           ),
                           child: InkWell(
                            onTap: _showResumePreview,
                            borderRadius: BorderRadius.circular(12),
                            hoverColor: theme.colorScheme.secondary.withAlpha((0.05 * 255).round()),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 14 : 24,
                                vertical: isMobile ? 12 : 20,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.article_outlined, size: isMobile? 24 : 40, color: theme.colorScheme.secondary),
                                  SizedBox(width: isMobile ? 12 : 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'View My Professional Resume',
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: isMobile? 15 : 20,
                                            color: _isCardHovered ? theme.colorScheme.secondary : theme.textTheme.titleLarge?.color,
                                          ),
                                        ),
                                        SizedBox(height: isMobile ? 2 : 5),
                                        Text(
                                          'Click to open a preview or download the PDF.',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: isMobile ? 11 : 14,
                                            color: theme.textTheme.bodyMedium?.color?.withAlpha((0.8 * 255).round()),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: isMobile ? 6 : 12),
                                  ElevatedButton.icon(
                                    icon: Icon(Icons.download_outlined, size: isMobile ? 14 : 18),
                                    label: Text(isMobile ? 'Get' : 'Download'),
                                    onPressed: _downloadResume,
                                    style: downloadButtonStyle, // Apply the new button style
                                  ),
                                ],
                              ),
                            ),
                          ),
                         ),
                       ),
                    )
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
      6 + rand.nextDouble() * 8, 
      0.05 + rand.nextDouble() * 0.08, 
      rand.nextDouble() * 2 * pi, 
      rand.nextDouble() * 0.35 - 0.17, 
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
      final dx = p.x * size.width + cos(p.direction + t * 2 * pi * (p.drift + 0.6)) * p.drift * size.width * 0.16;
      final dy = (p.y * size.height + sin(p.direction + t * 2 * pi * (p.drift + 0.6)) * p.drift * size.height * 0.16 + t * p.speed * size.height) % size.height;
      canvas.drawCircle(Offset(dx, dy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

const String _svgBlob = '''<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg"><path fill="currentColor" d="M44.8,-67.6C56.2,-60.2,62.7,-44.2,68.2,-28.7C73.7,-13.2,78.2,1.8,75.2,15.2C72.2,28.6,61.7,40.4,49.2,48.7C36.7,57,22.2,61.8,7.2,66.2C-7.8,70.6,-23.5,74.6,-36.2,69.2C-48.9,63.8,-58.6,49,-65.2,34.1C-71.8,19.2,-75.3,4.1,-74.2,-11.2C-73.1,-26.5,-67.4,-41.9,-56.6,-49.2C-45.8,-56.5,-29.9,-55.7,-14.7,-62.2C0.5,-68.7,15.9,-82.5,29.7,-81.2C43.5,-79.9,56.2,-73.1,44.8,-67.6Z" transform="translate(100 100)"/></svg>'''; 