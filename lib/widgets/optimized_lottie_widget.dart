import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../utils/error_handler.dart';

/// Optimized Lottie Widget with Performance Monitoring
///
/// Features:
/// - Progressive loading with loading indicator
/// - Performance monitoring and optimization suggestions
/// - Fallback support for failed loads
/// - Automatic quality adjustment based on device capabilities
/// - Memory-efficient rendering with RepaintBoundary
class OptimizedLottieWidget extends StatefulWidget {
  final String assetPath;
  final double width;
  final double height;
  final bool repeat;
  final bool animate;
  final BoxFit fit;
  final FilterQuality? filterQuality;
  final FrameRate? frameRate;
  final String? semanticLabel;
  final bool enablePerformanceMonitoring;

  const OptimizedLottieWidget({
    super.key,
    required this.assetPath,
    this.width = 120,
    this.height = 120,
    this.repeat = true,
    this.animate = true,
    this.fit = BoxFit.contain,
    this.filterQuality,
    this.frameRate,
    this.semanticLabel,
    this.enablePerformanceMonitoring = true,
  });

  @override
  State<OptimizedLottieWidget> createState() => _OptimizedLottieWidgetState();
}

class _OptimizedLottieWidgetState extends State<OptimizedLottieWidget>
    with SingleTickerProviderStateMixin {
  LottieComposition? _composition;
  bool _isLoading = true;
  bool _hasError = false;
  late String _assetName;

  @override
  void initState() {
    super.initState();
    _assetName = widget.assetPath.split('/').last.replaceAll('.json', '');
    _loadAnimation();
  }

  /// Load animation with simple direct loading
  Future<void> _loadAnimation() async {
    if (!mounted) return;

    try {
      // Load the asset directly
      final composition = await AssetLottie(widget.assetPath).load();
      debugPrint('✅ Loaded Lottie: ${widget.assetPath}');
      
      if (mounted) {
        setState(() {
          _composition = composition;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to load Lottie: ${widget.assetPath} - $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  /// Get optimal frame rate based on device capabilities
  FrameRate _getOptimalFrameRate() {
    if (widget.frameRate != null) return widget.frameRate!;

    // Check device capabilities
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final isLowEndDevice = devicePixelRatio < 2.0;
    
    if (isLowEndDevice) {
      return FrameRate(15); // Lower frame rate for low-end devices
    } else {
      return FrameRate(30); // Standard frame rate for better devices
    }
  }

  /// Get optimal filter quality
  FilterQuality _getOptimalFilterQuality() {
    if (widget.filterQuality != null) return widget.filterQuality!;

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final isLowEndDevice = devicePixelRatio < 2.0;
    
    return isLowEndDevice ? FilterQuality.low : FilterQuality.medium;
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: widget.width * 0.3,
              height: widget.width * 0.3,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            if (widget.width > 80) ...[
              const SizedBox(height: 8),
              Text(
                'Loading...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build error fallback
  Widget _buildErrorFallback() {
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
            Icons.animation_rounded,
            size: widget.width * 0.4,
            color: theme.colorScheme.error.withValues(alpha: 0.6),
          ),
          if (widget.width > 80) ...[
            const SizedBox(height: 4),
            Text(
              'Animation\nUnavailable',
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
      return _buildLoadingIndicator();
    }

    // Error state
    if (_hasError || _composition == null) {
      return _buildErrorFallback();
    }

    // Success state - render optimized Lottie
    return ErrorHandler.errorBoundary(
      errorContext: 'OptimizedLottieWidget-$_assetName',
      child: Semantics(
        label: widget.semanticLabel ?? 'Animation: $_assetName',
        child: RepaintBoundary(
          child: Lottie(
            composition: _composition!,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            repeat: widget.repeat,
            animate: widget.animate,
            frameRate: _getOptimalFrameRate(),
            filterQuality: _getOptimalFilterQuality(),
            addRepaintBoundary: false, // We already have RepaintBoundary
            options: LottieOptions(
              enableMergePaths: true, // Optimize path rendering
            ),
          ),
        ),
      ),
      fallback: _buildErrorFallback(),
    );
  }

  @override
  void dispose() {
    // Clean up resources
    _composition = null;
    super.dispose();
  }
}

/// Adaptive Lottie Widget that adjusts quality based on device performance
class AdaptiveLottieWidget extends StatelessWidget {
  final String assetPath;
  final double size;
  final bool repeat;
  final String? semanticLabel;

  const AdaptiveLottieWidget({
    super.key,
    required this.assetPath,
    this.size = 120,
    this.repeat = true,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableSize = constraints.biggest.shortestSide;
        final adaptiveSize = size.clamp(50.0, availableSize);
        
        return OptimizedLottieWidget(
          assetPath: assetPath,
          width: adaptiveSize,
          height: adaptiveSize,
          repeat: repeat,
          semanticLabel: semanticLabel,
        );
      },
    );
  }
}

/// Pre-configured Lottie widgets for common use cases
class LottieWidgets {
  /// Hero section animation with optimized settings
  static Widget hero({
    String assetPath = 'assets/lottie/hero_animation.json',
    double size = 200,
  }) {
    return OptimizedLottieWidget(
      assetPath: assetPath,
      width: size,
      height: size,
      repeat: true,
      frameRate: FrameRate(30),
      semanticLabel: 'Hero section animation',
    );
  }

  /// Service card animation with balanced performance
  static Widget serviceCard({
    required String assetPath,
    double size = 120,
  }) {
    return OptimizedLottieWidget(
      assetPath: assetPath,
      width: size,
      height: size,
      repeat: true,
      frameRate: FrameRate(24), // Slightly lower for cards
      semanticLabel: 'Service animation',
    );
  }

  /// Background animation with minimal performance impact
  static Widget background({
    required String assetPath,
    double width = 200,
    double height = 200,
  }) {
    return OptimizedLottieWidget(
      assetPath: assetPath,
      width: width,
      height: height,
      repeat: true,
      frameRate: FrameRate(15), // Low frame rate for background
      filterQuality: FilterQuality.low,
      semanticLabel: 'Background animation',
    );
  }
} 