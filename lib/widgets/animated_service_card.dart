import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/error_handler.dart';
import 'optimized_lottie_widget.dart';

/// AnimatedServiceCard displays a service with a posh animation and elegant style.
///
/// Features:
/// - Optimized Lottie animations with performance monitoring
/// - Elegant hover and tap animations
/// - Professional styling with shadows and transitions
/// - Error boundaries with graceful fallbacks
/// - Responsive design with adaptive sizing
///
/// - [title]: The service title.
/// - [description]: Short description of the service.
/// - [lottieAsset]: Path to the Lottie animation asset.
/// - [onTap]: Optional callback when the card is tapped.
/// - [color]: Optional background color for the card.
class AnimatedServiceCard extends StatefulWidget {
  final String title;
  final String description;
  final String lottieAsset;
  final VoidCallback? onTap;
  final Color? color;

  const AnimatedServiceCard({
    super.key,
    required this.title,
    required this.description,
    required this.lottieAsset,
    this.onTap,
    this.color,
  });

  @override
  State<AnimatedServiceCard> createState() => _AnimatedServiceCardState();
}

class _AnimatedServiceCardState extends State<AnimatedServiceCard> {
  bool _isHovered = false;
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return ErrorHandler.errorBoundary(
      errorContext: 'AnimatedServiceCard-${widget.title}',
      child: _buildCard(context),
      fallback: _buildErrorFallback(context),
    );
  }

  /// Build the main card widget
  Widget _buildCard(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isTapped = true),
        onTapUp: (_) => setState(() => _isTapped = false),
        onTapCancel: () => setState(() => _isTapped = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..scale(_isTapped ? 0.97 : (_isHovered ? 1.04 : 1.0)),
          decoration: BoxDecoration(
            color: widget.color ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (_isHovered ? theme.colorScheme.secondary : (widget.color ?? theme.colorScheme.secondary)).withValues(alpha: 0.13),
                blurRadius: _isHovered ? 32 : 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Use optimized Lottie widget for better performance
              LottieWidgets.serviceCard(
                assetPath: widget.lottieAsset,
                size: 120,
              ),
              const SizedBox(height: 18),
              Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.brightness == Brightness.dark ? Colors.white : theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                widget.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.85)
                      : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.85),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms, curve: Curves.easeOut).slideY(begin: 0.18, end: 0, duration: 600.ms, curve: Curves.easeOut),
      ),
    );
  }

  /// Build error fallback widget
  Widget _buildErrorFallback(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.animation_rounded,
            size: 120,
            color: theme.colorScheme.error.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 18),
          Text(
            widget.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Service temporarily unavailable',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error.withValues(alpha: 0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 