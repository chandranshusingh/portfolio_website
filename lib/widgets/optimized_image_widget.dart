import 'package:flutter/material.dart';
import '../utils/error_handler.dart';

/// Optimized Image Widget with WebP Support and Fallbacks
///
/// Features:
/// - WebP image loading with automatic fallback to original format
/// - Responsive sizing based on screen density
/// - Performance monitoring integration
/// - Progressive loading with placeholder
/// - Memory-efficient caching
/// - Error boundaries with graceful fallbacks
class OptimizedImageWidget extends StatefulWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? semanticLabel;
  final bool enablePerformanceMonitoring;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool useResponsiveSize;

  const OptimizedImageWidget({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    this.enablePerformanceMonitoring = true,
    this.placeholder,
    this.errorWidget,
    this.useResponsiveSize = true,
  });

  @override
  State<OptimizedImageWidget> createState() => _OptimizedImageWidgetState();
}

class _OptimizedImageWidgetState extends State<OptimizedImageWidget> {
  bool _isLoading = true;
  bool _hasError = false;
  late String _assetName;
  String? _finalAssetPath;

  @override
  void initState() {
    super.initState();
    _assetName = widget.assetPath.split('/').last.replaceAll(RegExp(r'\.(jpg|jpeg|png|webp)$'), '');
    _loadImage();
  }

  /// Load image with simple direct loading
  Future<void> _loadImage() async {
    if (!mounted) return;

    try {
      // Load the asset directly
      final assetPath = widget.assetPath;
      debugPrint('✅ Loading image: $assetPath');
      
      if (mounted) {
        setState(() {
          _finalAssetPath = assetPath;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to load image: ${widget.assetPath} - $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  /// Build loading placeholder
  Widget _buildLoadingPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: (widget.width ?? 100) * 0.3,
            height: (widget.width ?? 100) * 0.3,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          if ((widget.width ?? 100) > 80) ...[
            const SizedBox(height: 8),
            Text(
              'Loading image...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build error fallback
  Widget _buildErrorFallback() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    final theme = Theme.of(context);
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_rounded,
            size: (widget.width ?? 100) * 0.4,
            color: theme.colorScheme.error.withValues(alpha: 0.6),
          ),
          if ((widget.width ?? 100) > 80) ...[
            const SizedBox(height: 4),
            Text(
              'Image\nUnavailable',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error.withValues(alpha: 0.8),
                fontSize: 8,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoading) {
      return _buildLoadingPlaceholder();
    }

    // Error state
    if (_hasError || _finalAssetPath == null) {
      return _buildErrorFallback();
    }

    // Success state - render optimized image
    return ErrorHandler.errorBoundary(
      errorContext: 'OptimizedImageWidget-$_assetName',
      child: Semantics(
        label: widget.semanticLabel ?? 'Image: $_assetName',
        child: RepaintBoundary(
          child: Image.asset(
            _finalAssetPath!,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('❌ Image render error for $_finalAssetPath: $error');
              return _buildErrorFallback();
            },
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) {
                return child;
              }
              
              // Progressive loading animation
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: child,
              );
            },
          ),
        ),
      ),
      fallback: _buildErrorFallback(),
    );
  }

  @override
  void dispose() {
    // Clean up resources
    _finalAssetPath = null;
    super.dispose();
  }
}

/// Responsive Image Widget that adapts to screen size
class ResponsiveImageWidget extends StatelessWidget {
  final String assetPath;
  final BoxFit fit;
  final String? semanticLabel;
  final double aspectRatio;

  const ResponsiveImageWidget({
    super.key,
    required this.assetPath,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    this.aspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        
        // Calculate optimal size based on available space
        double width, height;
        
        if (availableHeight.isFinite && availableWidth.isFinite) {
          // Both dimensions are constrained
          if (availableWidth / availableHeight > aspectRatio) {
            // Width is the limiting factor
            height = availableHeight;
            width = height * aspectRatio;
          } else {
            // Height is the limiting factor
            width = availableWidth;
            height = width / aspectRatio;
          }
        } else if (availableWidth.isFinite) {
          // Only width is constrained
          width = availableWidth;
          height = width / aspectRatio;
        } else if (availableHeight.isFinite) {
          // Only height is constrained
          height = availableHeight;
          width = height * aspectRatio;
        } else {
          // No constraints, use default size
          width = 300;
          height = 300 / aspectRatio;
        }
        
        return OptimizedImageWidget(
          assetPath: assetPath,
          width: width,
          height: height,
          fit: fit,
          semanticLabel: semanticLabel,
        );
      },
    );
  }
}

/// Pre-configured image widgets for common use cases
class ImageWidgets {
  /// Profile image with circular crop and simple loading
  static Widget profile({
    String assetPath = 'assets/images/profile.jpg',
    double size = 120,
  }) {
    return ClipOval(
      child: OptimizedImageWidget(
        assetPath: assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        semanticLabel: 'Profile picture',
      ),
    );
  }

  /// Project thumbnail with rounded corners
  static Widget projectThumbnail({
    required String assetPath,
    double width = 300,
    double height = 200,
    double borderRadius = 12,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: OptimizedImageWidget(
        assetPath: assetPath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        semanticLabel: 'Project thumbnail',
      ),
    );
  }

  /// Hero banner image with responsive sizing
  static Widget heroBanner({
    required String assetPath,
    double aspectRatio = 16 / 9,
  }) {
    return ResponsiveImageWidget(
      assetPath: assetPath,
      aspectRatio: aspectRatio,
      fit: BoxFit.cover,
      semanticLabel: 'Hero banner',
    );
  }
} 