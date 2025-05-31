import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import '../utils/error_handler.dart';

/// Contact section of the portfolio website with slide-in and fade-in animation and posh style.
/// 
/// Features professional contact cards with clickable email and LinkedIn links,
/// elegant icons, and smooth hover animations.
class ContactSection extends StatefulWidget {
  final ScrollController? scrollController;
  const ContactSection({super.key, this.scrollController});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> with TickerProviderStateMixin {
  double _opacity = 0.0;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isHovered = false;
  late AnimationController _particleController;
  final int _particleCount = 5;
  late List<_Particle> _particles;

  // Contact information
  final String _email = 'chandranshu.singh@outlook.com';
  final String _linkedInUrl = 'https://linkedin.com/in/chandranshusingh/';
  final String _linkedInDisplay = 'linkedin.com/in/chandranshusingh/';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
    _particles = List.generate(_particleCount, (i) => _Particle.random());
  }

  @override
  void dispose() {
    ErrorHandler.safeDisposeControllers(
      [_controller, _particleController],
      names: ['ContactMainController', 'ContactParticleController'],
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

  /// Opens email client with pre-filled email
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: _email,
      query: 'subject=Hello Chandranshu&body=Hi Chandranshu,\n\nI would like to connect with you.\n\nBest regards,',
    );
    
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (mounted) {
          _showSnackBar('Could not open email client. Please contact directly at $_email');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error opening email client. Please contact directly at $_email');
      }
    }
  }

  /// Opens LinkedIn profile in new tab/browser
  Future<void> _launchLinkedIn() async {
    final Uri linkedInUri = Uri.parse(_linkedInUrl);
    
    try {
      if (await canLaunchUrl(linkedInUri)) {
        await launchUrl(
          linkedInUri,
          mode: LaunchMode.externalApplication, // Opens in new tab/browser
        );
      } else {
        if (mounted) {
          _showSnackBar('Could not open LinkedIn. Please visit: $_linkedInDisplay');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error opening LinkedIn. Please visit: $_linkedInDisplay');
      }
    }
  }

  /// Shows a helpful snackbar message
  void _showSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Creates a professional contact card with icon, label and action
  Widget _buildContactCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    required bool isMobile,
    required ThemeData theme,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          hoverColor: theme.colorScheme.secondary.withAlpha(20),
          splashColor: theme.colorScheme.secondary.withAlpha(30),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withAlpha(80),
                width: 1,
              ),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.surface.withAlpha(120),
                  theme.colorScheme.surface.withAlpha(60),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.brightness == Brightness.dark
                      ? Colors.black.withAlpha(40)
                      : Colors.black.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (iconColor ?? theme.colorScheme.secondary).withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? theme.colorScheme.secondary,
                    size: isMobile ? 20 : 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withAlpha(200),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: GoogleFonts.inter(
                          fontSize: isMobile ? 15 : 17,
                          fontWeight: FontWeight.w500,
                          color: theme.brightness == Brightness.dark 
                              ? Colors.white 
                              : theme.colorScheme.primary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: theme.colorScheme.onSurface.withAlpha(120),
                  size: 16,
                ),
              ],
            ),
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
    final double headingSize = isMobile ? 28 : 36;
    final EdgeInsets sectionPadding = isMobile
        ? const EdgeInsets.symmetric(vertical: 56, horizontal: 16)
        : const EdgeInsets.symmetric(vertical: 80, horizontal: 40);

    double parallax = 0;
    if (widget.scrollController != null && widget.scrollController!.hasClients) {
      parallax = (widget.scrollController!.offset * 0.05).clamp(-20.0, 20.0); 
    }

    return VisibilityDetector(
      key: const Key('contact-section'),
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
                        right: isMobile ? 10 : 25, 
                        top: isMobile ? 15 : 35, 
                        child: AnimatedBuilder(
                          animation: _particleController,
                          builder: (context, child) {
                            final double t = _particleController.value;
                            return Transform.rotate(
                              angle: t * 2 * pi / 2, 
                              child: Opacity(
                                opacity: 0.06, 
                                child: SvgPicture.string(_svgBlob, 
                                    width: isMobile ? 40 : 75,
                                    height: isMobile ? 40 : 75,
                                    colorFilter: ColorFilter.mode(
                                      theme.colorScheme.secondary.withAlpha((0.55 * 255).round()),
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
                                  theme.colorScheme.secondary.withAlpha((0.45 * 255).round()), 
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
                    // Section title with hover animation
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
                            color: _isHovered && !isMobile
                                ? theme.colorScheme.secondary
                                : theme.textTheme.displayMedium!.color,
                          ),
                          child: const Text('Contact'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Subtitle
                    Text(
                      'Let\'s connect and discuss opportunities',
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withAlpha(180),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Email contact card
                    _buildContactCard(
                      icon: Icons.email_rounded,
                      label: 'Email',
                      value: _email,
                      onTap: _launchEmail,
                      isMobile: isMobile,
                      theme: theme,
                      iconColor: Colors.orange.shade600,
                    ),
                    
                    // LinkedIn contact card
                    _buildContactCard(
                      icon: Icons.work_rounded, // Using work icon as LinkedIn icon alternative
                      label: 'LinkedIn',
                      value: _linkedInDisplay,
                      onTap: _launchLinkedIn,
                      isMobile: isMobile,
                      theme: theme,
                      iconColor: const Color(0xFF0077B5), // LinkedIn blue
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Additional contact note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.secondary.withAlpha(60),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: theme.colorScheme.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Available for consulting, partnerships, and exciting collaborations.',
                              style: GoogleFonts.inter(
                                fontSize: isMobile ? 14 : 15,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.secondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 48),
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
      5 + rand.nextDouble() * 7, 
      0.06 + rand.nextDouble() * 0.09, 
      rand.nextDouble() * 2 * pi, 
      rand.nextDouble() * 0.4 - 0.2, 
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
      final dx = p.x * size.width + cos(p.direction + t * 2 * pi * (p.drift + 0.5)) * p.drift * size.width * 0.15;
      final dy = (p.y * size.height + sin(p.direction + t * 2 * pi * (p.drift + 0.5)) * p.drift * size.height * 0.15 + t * p.speed * size.height) % size.height;
      canvas.drawCircle(Offset(dx, dy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

const String _svgBlob = '''<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg"><path fill="currentColor" d="M44.8,-67.6C56.2,-60.2,62.7,-44.2,68.2,-28.7C73.7,-13.2,78.2,1.8,75.2,15.2C72.2,28.6,61.7,40.4,49.2,48.7C36.7,57,22.2,61.8,7.2,66.2C-7.8,70.6,-23.5,74.6,-36.2,69.2C-48.9,63.8,-58.6,49,-65.2,34.1C-71.8,19.2,-75.3,4.1,-74.2,-11.2C-73.1,-26.5,-67.4,-41.9,-56.6,-49.2C-45.8,-56.5,-29.9,-55.7,-14.7,-62.2C0.5,-68.7,15.9,-82.5,29.7,-81.2C43.5,-79.9,56.2,-73.1,44.8,-67.6Z" transform="translate(100 100)"/></svg>''';
